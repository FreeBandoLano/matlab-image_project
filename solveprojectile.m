function metrics = solveprojectile(v0, theta, h0, includeDrag, scenario_str, targetX, targetY, bounceEfficiency)
    g = 9.81; % Gravity
    % Initialize targetX, targetY if not provided (e.g. from older calls or if varargin is not used robustly)
    if nargin < 6, targetX = NaN; end
    if nargin < 7, targetY = NaN; end
    if nargin < 8, bounceEfficiency = NaN; end % Default if not provided

    metrics = struct('t_flight', NaN, 'X_range', NaN, 'h_max', NaN, ...
                     'target_status_str', 'N/A (No Target Specified)', ...
                     't_flight_s2', NaN, 'X_range_s2', NaN, 'h_max_s2', NaN);

    x_traj = []; y_traj = []; % Initialize for target check regardless of scenario if target is given
    final_x_traj = []; final_y_traj = [];
    time_offset_for_second_flight = 0;

    if strcmp(scenario_str, 'General Launch') || strcmp(scenario_str, 'Target Clearance Problem') || strcmp(scenario_str, 'Horizontal Launch (No Bounce)')
        if strcmp(scenario_str, 'Horizontal Launch (No Bounce)'), theta = 0; end % Ensure theta is 0
        
        if ~includeDrag
            [final_x_traj, final_y_traj, t_f, X_r, h_m] = noDragProjectile_local(v0, theta, h0, g);
        else
            [final_x_traj, final_y_traj, t_f, X_r, h_m] = dragProjectile_local(v0, theta, h0, g);
        end
        metrics.t_flight = t_f;
        metrics.X_range = X_r;
        metrics.h_max = h_m;
        x_traj = final_x_traj; % For target check below
        y_traj = final_y_traj;
        
    elseif strcmp(scenario_str, 'Horizontal Launch with Bounce')
        theta = 0; % Enforce horizontal launch
        friction_factor_bounce = 0.9; % Assume some horizontal velocity loss on bounce

        % --- First Flight ---
        if ~includeDrag
            [x1, y1, t_f1, X_r1, h_m1, vx_impact1, vy_impact1] = noDragProjectile_local(v0, theta, h0, g);
        else
            [x1, y1, t_f1, X_r1, h_m1, vx_impact1, vy_impact1] = dragProjectile_local(v0, theta, h0, g);
        end
        
        final_x_traj = x1;
        final_y_traj = y1;
        metrics.h_max = h_m1; % Max height of first flight, will be updated if second is higher
        time_offset_for_second_flight = t_f1;

        % --- Check for valid impact and bounce efficiency ---
        if isempty(x1) || X_r1 == 0 || isnan(bounceEfficiency) || bounceEfficiency <= 0
            % No first flight or no bounce, treat as single segment
            metrics.t_flight = t_f1;
            metrics.X_range = X_r1;
            metrics.h_max = h_m1; 
            if isnan(bounceEfficiency) || bounceEfficiency <=0
                metrics.target_status_str = 'Bounce ignored (efficiency <=0 or NaN)'; 
            end
        else
            % --- Second Flight (Bounce) ---
            v0_2_x = vx_impact1 * friction_factor_bounce;
            v0_2_y = -vy_impact1 * bounceEfficiency;
            
            % New initial velocity and angle for the bounced projectile
            v0_2 = sqrt(v0_2_x^2 + v0_2_y^2);
            theta_2 = atan2d(v0_2_y, v0_2_x); % atan2d for correct quadrant
            h0_2 = 0; % Starts from ground

            if v0_2 < 1e-3 % If new velocity is negligible, no real second flight
                [x2, y2, t_f2, X_r2, h_m2] = deal([], [], 0, 0, 0);
            else
                if ~includeDrag
                    [x2_local, y2_local, t_f2, X_r2_local, h_m2] = noDragProjectile_local(v0_2, theta_2, h0_2, g);
                else
                    [x2_local, y2_local, t_f2, X_r2_local, h_m2] = dragProjectile_local(v0_2, theta_2, h0_2, g);
                end
                x2 = x1(end) + x2_local; % Offset x coordinates of second flight
                y2 = y2_local;
            end

            % Concatenate trajectories
            % Avoid duplicate point at bounce if x1/y1 already ends at impact point perfectly
            if ~isempty(x2)
                final_x_traj = [x1, x2(2:end)]; % x2(1) is 0 relative to bounce point, so start from x2(2)
                final_y_traj = [y1, y2(2:end)];
            end
            
            metrics.t_flight = t_f1 + t_f2;
            metrics.X_range = x1(end) + X_r2_local; % X_r1 is x1(end)
            metrics.h_max = max(h_m1, h_m2); % Max height over both flights
        end
        x_traj = final_x_traj; % For target check below, use the full trajectory
        y_traj = final_y_traj;

    elseif strcmp(scenario_str, 'Double Projectile')
        [x1, y1, t_f1, X_r1, h_m1] = noDragProjectile_local(v0, theta, h0, g);
        [x2_dp, y2_dp, ~, ~, ~] = noDragProjectile_local(v0, theta + 10, h0, g);
        metrics.t_flight = t_f1;
        metrics.X_range = X_r1;
        metrics.h_max = h_m1;
        x_traj = x1; y_traj = y1; % Target check on first projectile
        % Animation will be handled by animateDoubleProjectile_local
        final_x_traj = x1; final_y_traj = y1; % So single animation call below doesn't error
        animateDoubleProjectile_local(x1, y1, x2_dp, y2_dp);
    else
        disp(['Unknown scenario: ', scenario_str]);
        metrics.target_status_str = 'Invalid Scenario';
        return; % Exit if scenario is unknown
    end

    % Animate the (potentially combined) trajectory if not double projectile (which handles its own animation)
    if ~strcmp(scenario_str, 'Double Projectile')
        animateProjectile_local(final_x_traj, final_y_traj);
    end

    % Perform Target Check if targetX and targetY are valid numbers
    % and we have a trajectory (x_traj, y_traj from single or first of double)
    if ~isnan(targetX) && ~isnan(targetY) && ~isempty(x_traj)
        metrics.target_status_str = 'Evaluating...'; % Initial status
        
        % Find height of projectile at targetX
        % Interpolate if targetX is within the range of x_traj
        if targetX >= x_traj(1) && targetX <= x_traj(end)
            try
                proj_height_at_targetX = interp1(x_traj, y_traj, targetX, 'linear', 'extrap'); % Allow extrap for edge cases
                
                % Check for NaN result from interp1 if targetX is outside unique x_traj points or x_traj is not monotonic
                if isnan(proj_height_at_targetX)
                     if targetX > x_traj(end) % it means it fell short
                        metrics.target_status_str = sprintf('Fell Short (Range: %.2fm)', x_traj(end));
                     else % other interp issue
                        metrics.target_status_str = 'Target X invalid for trajectory';
                     end
                else
                    tolerance = 0.05; % 5cm tolerance for hitting target height
                    if proj_height_at_targetX >= targetY - tolerance && proj_height_at_targetX <= targetY + tolerance 
                        metrics.target_status_str = sprintf('Hit Target (at y=%.2fm)', proj_height_at_targetX);
                    elseif proj_height_at_targetX > targetY
                        metrics.target_status_str = sprintf('Cleared Target (Proj y=%.2fm)', proj_height_at_targetX);
                    else % proj_height_at_targetX < targetY
                        metrics.target_status_str = sprintf('Below Target (Proj y=%.2fm)', proj_height_at_targetX);
                    end
                end
            catch interp_ME
                 metrics.target_status_str = 'Interpolation Error for Target';
                 disp(interp_ME.getReport());
            end
        elseif targetX < x_traj(1) % Target is before launch point
            metrics.target_status_str = 'Target X is behind launch point';
        else % targetX > x_traj(end) - Projectile fell short of Target X
            metrics.target_status_str = sprintf('Fell Short of Target X (Range: %.2fm)', x_traj(end));
        end
    elseif ~isnan(targetX) && ~isnan(targetY) && isempty(x_traj)
        metrics.target_status_str = 'No trajectory to check against.';
    % If targetX or targetY is NaN, the default 'N/A (No Target Specified)' remains from initialization
    end

end

% Local functions
function [x, y, t_flight_val, X_range_val, h_max_val, vx_impact, vy_impact] = noDragProjectile_local(v0, theta, h0, g)
    thetaRad = deg2rad(theta);
    vy0 = v0*sin(thetaRad);
    vx0 = v0*cos(thetaRad);
    vx_impact = vx0; % No drag, so vx is constant
    vy_impact = 0; % Initialize

    determinant = vy0^2 + 2*g*h0;
    t_flight_val = 0;
    if determinant >= 0
        t1 = (vy0 + sqrt(determinant)) / g;
        t2 = (vy0 - sqrt(determinant)) / g;
        if t1 > 0 && t1 >= t2, t_flight_val = t1;
        elseif t2 > 0, t_flight_val = t2;
        end
    end

    if t_flight_val == 0 || v0 < 1e-6 % Also check if v0 is practically zero
        x = [0]; y = [h0]; 
        if h0 == 0, y = [0]; end
        X_range_val = 0;
        h_max_val = h0;
        vy_impact = vy0 - g*t_flight_val; % Even if t_flight is 0, this is initial vy
        if h0 == 0 && vy0 <=0, vy_impact = vy0; else vy_impact = -sqrt(vy0^2 + 2*g*h0) ; end % More direct for impact if no flight time
        if v0 < 1e-6, vy_impact = 0; vx_impact = 0; end
        return;
    end
    
    t_points = linspace(0, t_flight_val, 300);
    x = vx0*t_points;
    y_calc = h0 + vy0*t_points - 0.5*g*t_points.^2;
    vy_impact = vy0 - g*t_flight_val;
    
    y = max(y_calc, 0);
    first_ground_idx = find(y_calc <= 1e-6, 1, 'first');
    if ~isempty(first_ground_idx) && first_ground_idx <= length(x)
        x = x(1:first_ground_idx);
        y = y(1:first_ground_idx);
        if ~isempty(y), y(end) = 0; end
         % Adjust t_flight_val if trajectory is cut short by index
        if first_ground_idx < length(t_points)
            t_flight_val = t_points(first_ground_idx);
            vy_impact = vy0 - g*t_flight_val;
        end
    end

    if isempty(x), x = [0]; y = [h0]; X_range_val = 0; h_max_val = h0;
    else, X_range_val = x(end); h_max_val = max(y); if isempty(h_max_val), h_max_val=h0; end
    end
end

function [x, y, t_flight_val, X_range_val, h_max_val, vx_impact, vy_impact] = dragProjectile_local(v0, theta, h0, g)
    dt = 0.01; 
    k_val = 0.1; 
    m_val = 1; 
    coeff_drag_over_mass = k_val / m_val;

    thetaRad = deg2rad(theta);
    vx = v0*cos(thetaRad);
    vy = v0*sin(thetaRad);
    
    current_x = 0; 
    current_y = h0; 
    
    X_traj = [current_x];
    Y_traj = [current_y];
    
    max_iter = 50000; % Increased safety break
    iter_count = 0;

    while current_y >= -1e-3 && iter_count < max_iter && v0 > 1e-6
        ax = -coeff_drag_over_mass * vx;
        ay = -g - coeff_drag_over_mass * vy;
        
        vx_prev = vx; vy_prev = vy; % Store for impact velocity capture
        vx = vx + ax*dt;
        vy = vy + ay*dt;
        
        current_x = current_x + vx*dt;
        current_y = current_y + vy*dt;
        
        X_traj(end+1) = current_x; %#ok<AGROW>
        Y_traj(end+1) = current_y; %#ok<AGROW>
        
        iter_count = iter_count + 1;
        % More robust break condition for near ground and low velocity
        if current_y < 0.1 && sqrt(vx^2+vy^2) < 0.1 && iter_count > 10 % Avoid breaking too early if launched from ground
            if current_y <= 1e-3 % Check if it's essentially on the ground
                vx_impact = vx_prev; vy_impact = vy_prev;
                break;
            end
        end
        if iter_count == max_iter || v0 < 1e-6 % Store last known velocity if loop terminates early or no initial vel
            vx_impact = vx; vy_impact = vy;
        end
    end
    
    x = X_traj;
    y = Y_traj;

    % Trim data to ensure it stops at/after ground impact
    first_ground_idx = find(y <= 1e-6, 1, 'first');
    if ~isempty(first_ground_idx) && first_ground_idx <= length(x)
        x = x(1:first_ground_idx);
        y = y(1:first_ground_idx);
        if ~isempty(y), y(end) = 0; end
    else % If it never hits ground (e.g. launched straight up and loop ends on apex for some reason)
        if ~isempty(y), y(y<0) = 0; end % still clamp negative y
    end

    if isempty(x) || length(x) <= 1
        x = [0]; y = [h0];
        t_flight_val = 0;
        X_range_val = 0;
        h_max_val = h0;
        vx_impact = v0*cos(thetaRad); vy_impact = v0*sin(thetaRad); if v0 < 1e-6, vx_impact=0; vy_impact=0; end
    else
        t_flight_val = (length(x)-1)*dt;
        X_range_val = x(end);
        h_max_val = max(y); if isempty(h_max_val), h_max_val=h0; end
    end
    if isempty(x), x=[0]; end 
    if isempty(y), y=[h0]; end
end

function animateProjectile_local(x, y)
    if isempty(x) || isempty(y)
        disp('Animation skipped: No trajectory data.');
        return;
    end
    % Check if a figure for projectile motion already exists to reuse, or create new
    figTag = 'ProjectileMotionPlot';
    figHandle = findobj('Type', 'figure', 'Tag', figTag);
    if isempty(figHandle)
        figHandle = figure('Tag', figTag, 'Name', 'Projectile Motion');
    else
        figure(figHandle); % Bring to front
        clf(figHandle); % Clear previous plot in this figure
    end
    
    hold on;
    grid on;
    xlabel('Distance (m)');
    ylabel('Height (m)');
    title('Projectile Motion');
    
    ax_x_min = min(0, min(x));
    ax_x_max = max(x)*1.1; if ax_x_max == 0 && isempty(x), ax_x_max=1; elseif ax_x_max == 0 && ~isempty(x) && x(1)==0, ax_x_max=1; elseif isempty(x), ax_x_max=1; end
    ax_y_min = 0; %min(0, min(y)); % always start y-axis at 0 or below if needed
    ax_y_max = max(y)*1.1; if ax_y_max == 0 && isempty(y), ax_y_max=1; elseif ax_y_max == 0 && ~isempty(y) && y(1)==0, ax_y_max=1; elseif isempty(y), ax_y_max=1; end

    if ax_x_min == ax_x_max, ax_x_max = ax_x_min + 1; end
    if ax_y_min == ax_y_max, ax_y_max = ax_y_min + 1; end
    axis([ax_x_min ax_x_max ax_y_min ax_y_max]);
    
    h = plot(x(1),y(1),'bo', 'MarkerFaceColor','b', 'MarkerSize', 8);
    line_h = plot(x(1),y(1), 'b-', 'LineWidth', 1.5); % Handle for the trajectory line
    
    for i = 1:length(x)
        set(h, 'XData', x(i), 'YData', y(i));
        set(line_h, 'XData', x(1:i), 'YData', y(1:i)); % Update line to trace path
        drawnow;
        pause(0.01);
    end
    hold off;
end

function animateDoubleProjectile_local(x1, y1, x2, y2)
    if isempty(x1) || isempty(y1) || isempty(x2) || isempty(y2)
        disp('Double animation skipped: Incomplete trajectory data.');
        return;
    end
    figTag = 'DoubleProjectileMotionPlot';
    figHandle = findobj('Type', 'figure', 'Tag', figTag);
    if isempty(figHandle)
        figHandle = figure('Tag', figTag, 'Name', 'Double Projectile Motion');
    else
        figure(figHandle);
        clf(figHandle);
    end

    hold on;
    grid on;
    xlabel('Distance (m)');
    ylabel('Height (m)');
    title('Double Projectile Motion');

    ax_x_min = min(0, min([x1 x2]));
    ax_x_max = max([x1 x2])*1.1; if ax_x_max == 0, ax_x_max = 1; end
    ax_y_min = 0; %min(0, min([y1 y2]));
    ax_y_max = max([y1 y2])*1.1; if ax_y_max == 0, ax_y_max = 1; end
    
    if ax_x_min == ax_x_max, ax_x_max = ax_x_min + 1; end
    if ax_y_min == ax_y_max, ax_y_max = ax_y_min + 1; end
    axis([ax_x_min ax_x_max ax_y_min ax_y_max]);
    
    h1 = plot(x1(1),y1(1),'bo', 'MarkerFaceColor','b','MarkerSize',8);
    line1_h = plot(x1(1),y1(1), 'b-', 'LineWidth', 1.5);
    h2 = plot(x2(1),y2(1),'ro', 'MarkerFaceColor','r','MarkerSize',8);
    line2_h = plot(x2(1),y2(1), 'r-', 'LineWidth', 1.5);
    
    maxFrames = max(length(x1), length(x2));
    
    for i = 1:maxFrames
        if i <= length(x1)
            set(h1, 'XData', x1(i), 'YData', y1(i));
            set(line1_h, 'XData', x1(1:i), 'YData', y1(1:i));
        end
        if i <= length(x2)
            set(h2, 'XData', x2(i), 'YData', y2(i));
            set(line2_h, 'XData', x2(1:i), 'YData', y2(1:i));
        end
        drawnow;
        pause(0.01);
    end
    hold off;
end