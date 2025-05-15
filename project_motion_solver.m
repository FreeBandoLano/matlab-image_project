% Projectile Motion Solver with GUI
function project_motion_solver()

% Create the main window - increased height for bounce efficiency
fig = uifigure ('Name','Projectile Motion Solver','Position',[100 100 400 700]);

%Title
uilabel(fig, 'Text', 'Projectile Motion Solver', 'FontSize', 16, ...
        'FontWeight', 'bold', 'Position', [90 650 250 30]); % Y adjusted

%Initial Velocity
uilabel(fig, 'Text', 'Initial Velocity (m/s):', 'Position', [20 600 150 22]); % Y adjusted
velocityField = uieditfield(fig, 'numeric', 'Position', [180 600 150 22]); % Y adjusted

%Launch Angle
uilabel(fig,'Text','Launch Angle (degrees):','Position',[20 560 150 22]); % Y adjusted
angleField = uieditfield(fig,'numeric','Position',[180 560 150 22], 'Tag', 'angleField'); % Y adjusted, ADDED TAG

%Initial Height
uilabel(fig, 'Text', 'Initial Height (m):', 'Position', [20 520 150 22]); % Y adjusted
heightField = uieditfield(fig, 'numeric', 'Position', [180 520 150 22]); % Y adjusted

% Air Drag checkbox
dragCheck = uicheckbox(fig,'Text','Include Air Drag','Position',[20 480 150 22]); % Y adjusted

% Bounce Efficiency (only relevant for bounce scenario)
uilabel(fig, 'Text', 'Bounce Efficiency (0-1):', 'Position', [20 440 150 22]); % New field
app.bounceEfficiencyField = uieditfield(fig, 'numeric', 'Position', [180 440 150 22], 'Tag', 'bounceEfficiencyField', 'Value', 0.7);

%Scenario dropdown - added Horizontal Launch with Bounce
uilabel (fig,'Text','Select Scenario:','Position',[20 400 150 22]); % Y adjusted
scenarioDropdown = uidropdown(fig,'Items',{'General Launch','Target Clearance Problem', 'Horizontal Launch (No Bounce)', 'Horizontal Launch with Bounce','Double Projectile'},...
    'Position',[180 400 200 22], 'Tag', 'scenarioDropdown'); % Y adjusted, wider for new items
% Add ValueChangedFcn to manage visibility of bounceEfficiencyField
scenarioDropdown.ValueChangedFcn = @(src, event) scenarioChanged_callback(src, fig);

% --- Optional Target Inputs ---
uilabel(fig, 'Text', 'TARGET CHECK (Optional):', 'FontWeight', 'bold', 'Position', [20 360 200 22]); % Y adjusted
uilabel(fig, 'Text', 'Target X (m):', 'Position', [20 330 150 22]); % Y adjusted
app.targetXField = uieditfield(fig, 'numeric', 'Position', [180 330 150 22], 'Tag', 'targetXField');
uilabel(fig, 'Text', 'Target Y (m):', 'Position', [20 300 150 22]); % Y adjusted
app.targetYField = uieditfield(fig, 'numeric', 'Position', [180 300 150 22], 'Tag', 'targetYField');

%Solve Buttons
solveButton = uibutton(fig, 'Text', 'Solve', 'Position', [90 250 100 30], ... % Y adjusted
        'ButtonPushedFcn', @(btn,event) solveProjectile_callback(fig, velocityField, angleField, heightField, dragCheck, scenarioDropdown));

% --- UI Elements for Displaying Metrics ---
uilabel(fig, 'Text', 'RESULTS:', 'FontWeight', 'bold', 'Position', [20 210 150 22]); % Y adjusted
uilabel(fig, 'Text', 'Time of Flight (s):', 'Position', [20 180 150 22]); % Y adjusted
app.timeField = uilabel(fig, 'Text', '-', 'Position', [180 180 150 22], 'Tag', 'timeField'); 
uilabel(fig, 'Text', 'Max Height (m):', 'Position', [20 150 150 22]); % Y adjusted
app.maxHeightField = uilabel(fig, 'Text', '-', 'Position', [180 150 150 22], 'Tag', 'maxHeightField'); 
uilabel(fig, 'Text', 'Range (m):', 'Position', [20 120 150 22]); % Y adjusted
app.rangeField = uilabel(fig, 'Text', '-', 'Position', [180 120 150 22], 'Tag', 'rangeField'); 

% --- UI Element for Target Status ---
uilabel(fig, 'Text', 'Target Status:', 'Position', [20 90 150 22]); % Y adjusted
app.targetStatusField = uilabel(fig, 'Text', '-', 'Position', [180 90 200 22], 'Tag', 'targetStatusField');

% Initial call to set visibility based on default scenario
scenarioChanged_callback(scenarioDropdown, fig);

end 

% Callback for Scenario Dropdown Change
function scenarioChanged_callback(dropdown, figHandle)
    bounceEfficiencyField = findobj(figHandle, 'Tag', 'bounceEfficiencyField');
    bounceEfficiencyLabel = findobj(figHandle, 'Type', 'uilabel', 'Text', 'Bounce Efficiency (0-1):'); % Find by text
    angleField = findobj(figHandle, 'Tag', 'angleField'); % Assuming angleField has a Tag or get it via app struct if using classes
    % For simplicity, finding angleField by assuming it's already created. If not using app struct, pass it or find robustly.
    % A better way: assign tag to angleField: angleField = uieditfield(fig,'numeric','Position',[180 560 150 22], 'Tag', 'angleField');
    % Assuming angleField has been tagged as 'angleField' when created for this to work reliably.

    selectedScenario = dropdown.Value;
    if strcmp(selectedScenario, 'Horizontal Launch with Bounce')
        set(bounceEfficiencyField, 'Visible', 'on');
        set(bounceEfficiencyLabel, 'Visible', 'on');
        if ~isempty(angleField), set(angleField, 'Value', 0, 'Editable', 'off'); end % Set angle to 0 and make non-editable
    elseif strcmp(selectedScenario, 'Horizontal Launch (No Bounce)')
        set(bounceEfficiencyField, 'Visible', 'off');
        set(bounceEfficiencyLabel, 'Visible', 'off');
        if ~isempty(angleField), set(angleField, 'Value', 0, 'Editable', 'off'); end % Set angle to 0
    else
        set(bounceEfficiencyField, 'Visible', 'off');
        set(bounceEfficiencyLabel, 'Visible', 'off');
        if ~isempty(angleField), set(angleField, 'Editable', 'on'); end % Make editable for other scenarios
    end
end


% Main Solve Callback
function solveProjectile_callback(figHandle, velocityField, angleField, heightField, dragCheck, scenarioDropdown)
    v0 = velocityField.Value;
    theta = angleField.Value;
    h0 = heightField.Value;
    includeDrag = dragCheck.Value; 
    scenario = scenarioDropdown.Value; 

    targetXField = findobj(figHandle, 'Tag', 'targetXField');
    targetYField = findobj(figHandle, 'Tag', 'targetYField');
    targetX = targetXField.Value; 
    targetY = targetYField.Value; 

    bounceEfficiencyField = findobj(figHandle, 'Tag', 'bounceEfficiencyField');
    bounceEfficiency = NaN; % Default to NaN
    if strcmp(scenario, 'Horizontal Launch with Bounce')
        bounceEfficiency = bounceEfficiencyField.Value;
        if isempty(bounceEfficiency) || isnan(bounceEfficiency) || bounceEfficiency < 0 || bounceEfficiency > 1
            uialert(figHandle, 'Please enter a valid Bounce Efficiency (0-1).', 'Input Error');
            return;
        end
        theta = 0; % Enforce theta = 0 for horizontal launch with bounce scenario
    elseif strcmp(scenario, 'Horizontal Launch (No Bounce)')
        theta = 0; % Enforce theta = 0
    end

    if isempty(v0) || isnan(v0) || isempty(theta) || isnan(theta) || isempty(h0) || isnan(h0)
        uialert(figHandle, 'Please fill in required fields (Velocity, Angle, Height) with valid numbers.', 'Input Error');
        return; 
    end
    
    timeField = findobj(figHandle, 'Tag', 'timeField');
    maxHeightField = findobj(figHandle, 'Tag', 'maxHeightField');
    rangeField = findobj(figHandle, 'Tag', 'rangeField');
    targetStatusField = findobj(figHandle, 'Tag', 'targetStatusField');
    
    set(timeField, 'Text', 'Calculating...');
    set(maxHeightField, 'Text', 'Calculating...');
    set(rangeField, 'Text', 'Calculating...');
    set(targetStatusField, 'Text', 'Calculating...');
    drawnow;

    metrics = struct(); 
    try
        % Pass targetX, targetY, and bounceEfficiency to solveprojectile
        metrics = solveprojectile(v0, theta, h0, includeDrag, scenario, targetX, targetY, bounceEfficiency);
        
        if isstruct(metrics) && isfield(metrics, 't_flight') && ~isnan(metrics.t_flight)
            set(timeField, 'Text', sprintf('%.2f s', metrics.t_flight));
        else, set(timeField, 'Text', 'N/A'); end

        if isstruct(metrics) && isfield(metrics, 'h_max') && ~isnan(metrics.h_max)
            set(maxHeightField, 'Text', sprintf('%.2f m', metrics.h_max));
        else, set(maxHeightField, 'Text', 'N/A'); end

        if isstruct(metrics) && isfield(metrics, 'X_range') && ~isnan(metrics.X_range)
            set(rangeField, 'Text', sprintf('%.2f m', metrics.X_range));
        else, set(rangeField, 'Text', 'N/A'); end

        if isstruct(metrics) && isfield(metrics, 'target_status_str') && ~isempty(metrics.target_status_str)
            set(targetStatusField, 'Text', metrics.target_status_str);
        elseif ~isnan(targetX) && ~isnan(targetY) 
             set(targetStatusField, 'Text', 'Not Evaluated');
        else 
            set(targetStatusField, 'Text', 'N/A (No Target)');
        end

    catch ME
        uialert(figHandle, ['Error: ', ME.message], 'Runtime Error');
        disp(ME.getReport()); 
        set(timeField, 'Text', 'Error');
        set(maxHeightField, 'Text', 'Error');
        set(rangeField, 'Text', 'Error');
        set(targetStatusField, 'Text', 'Error');
    end
end



