function Instrument = artemis_scope_config

    % Example Config file for Hill Lab Nikon Microscope
    Instrument.Name = 'Artemis';
    Instrument.Location = 'Chapman B42';
    Instrument.DefaultCamera = 2;
    Instrument.DefaultOpticalPath = 5;
    Instrument.DefaultObjective = 1;
    Instrument.DefaultFilterCube = 3;
    Instrument.DefaultMultiplier = 1;


    Instrument.Scope.OpticalPaths = {1, 'Eyepiece', ''; ...
                                     2, 'Dragonfly2', 1; ...
                                     3, '', ''; ...
                                     4, '', ''; ...
                                     5, 'Grasshopper3', 2};
    Instrument.Scope.Objectives = {1, 4; ...
                                   2, 10; ...
                                   3, 20; ...
                                   4, 40; ...
                                   5, NaN; ...
                                   6, NaN };
    Instrument.Scope.ScalingFactors = readtable('Artemis_Scope_LengthScales.csv');
    Instrument.Scope.Multipliers = [1; 1.5];
    Instrument.Scope.Cubes = {1, 'Rhodamine'; ...
                              2, 'FITC'; ...
                              3, 'DAPI'; ...
                              4, ''; ...
                              5, ''; ...
                              6, '' }; 
    Instrument.Scope.Model = 'NikonTE2000-E';
    Instrument.Scope.AutoTurret = false;
    Instrument.Scope.AutoFilterCube = true;
    Instrument.Scope.AutoFocus = true;
    Instrument.Scope.AutoOpticalPath = true;
    Instrument.Scope.AutoMultiplier = false;
    Instrument.Scope.AutoXYStage = true;
    Instrument.Scope.Comport = 'COM2';
    Instrument.Scope.Baudrate = 9600;
    Instrument.Scope.DataBits = 8;
    Instrument.Scope.Parity = 'none';
    Instrument.Scope.StopBits = 1;

    Instrument.Stage.Name = 'BioPrecision2-LE2_Ludl6000';
    Instrument.Stage.Controller = 'MAC6000';
    Instrument.Stage.ComPort = 'COM6';
    Instrument.Stage.RequestToSend = 'off';
    Instrument.Stage.Timeout = 3;
    Instrument.Stage.Baudrate = 115200;
    Instrument.Stage.Parity = 'none';
    Instrument.Stage.Stopbits = 2;

    Instrument.Camera.Name = 'Flea3';
    Instrument.Camera.Format = 'F7_Mono8_1280x1024_Mode0';
    Instrument.Camera.ExposureTime = 10; % [ms]
    Instrument.Camera.ExposureMode = 'off';
    Instrument.Camera.FrameRateMode = 'off';
    Instrument.Camera.ShutterMode = 'manual';
    Instrument.Camera.Gain = 12;
    Instrument.Camera.Gamma = 1.15;
    Instrument.Camera.Brightness = 5.8594;

