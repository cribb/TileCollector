function varargout = TileCollectorUI(varargin)
% TILECOLLECTORUI MATLAB code for TileCollectorUI.fig
%      TILECOLLECTORUI, by itself, creates a new TILECOLLECTORUI or raises the existing
%      singleton*.
%
%      H = TILECOLLECTORUI returns the handle to a new TILECOLLECTORUI or the handle to
%      the existing singleton*.
%
%      TILECOLLECTORUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TILECOLLECTORUI.M with the given input arguments.
%
%      TILECOLLECTORUI('Property','Value',...) creates a new TILECOLLECTORUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TileCollectorUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TileCollectorUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TileCollectorUI

% Last Modified by GUIDE v2.5 02-Nov-2020 16:08:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TileCollectorUI_OpeningFcn, ...
                   'gui_OutputFcn',  @TileCollectorUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TileCollectorUI is made visible.
function TileCollectorUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TileCollectorUI (see VARARGIN)

% Choose default command line output for TileCollectorUI
handles.output = hObject;

% Load instrument configuration. This is hardcoded for now, but needs to be
% and option, maybe set in a menu item in the future.
handles.Instrument = hill_scope_config;
handles.scope = scope_open(handles.Instrument.Scope.Comport);
handles.ludl  = stage_open_Ludl(handles.Instrument.Stage.ComPort, ...
                                handles.Instrument.Stage.Name);
                            
% Pull the current values and set them as the session's default starting value                            
CurrentObjective = scope_get_nosepiece(handles.scope);
CurrentOpticalPath = scope_get_op_path(handles.scope);
CurrentFilterCube = scope_get_filterblock(handles.scope);
CurrentFocus = scope_get_focus(handles.scope);

% Populate the objectives popup menu based on what values are in the
% instrument's configuration file.
Objectives = handles.Instrument.Scope.Objectives;
Objectives = cellfun(@(x1)num2str(x1), Objectives, 'UniformOutput', false);
ObjectiveList = strcat(Objectives(:,2), 'X');
handles.popup_objectives.String = ObjectiveList;
handles.popup_objectives.Value = CurrentObjective;


% Pull the current microns per pixel calibration factor
mag = regexp(ObjectiveList(CurrentObjective), '(\d*)X', 'tokens');
mag = mag{1}{1};
handles.mag = str2double(mag);    
handles.mult = 1.0;


% Same for Optical Paths (Camera/Eyepiece selection)
OpticalPaths = handles.Instrument.Scope.OpticalPaths;
OpticalPaths = cellfun(@(x1)num2str(x1), OpticalPaths, 'UniformOutput', false);
OpticalPathList = OpticalPaths(:,2);
handles.popup_opticalpaths.String = OpticalPathList;
handles.popup_opticalpaths.Value = CurrentOpticalPath;

% Same for installed filter cubes
FilterCubes = handles.Instrument.Scope.Cubes;
FilterCubes = cellfun(@(x1)num2str(x1), FilterCubes, 'UniformOutput', false);
FilterCubeList = FilterCubes(:,2);
handles.popup_filtercubes.String = FilterCubeList;
handles.popup_filtercubes.Value = CurrentFilterCube;

% Populate the focus edit box with the current focus value
handles.edit_focus.String = num2str(CurrentFocus);

% Update handles structure
guidata(hObject, handles);

update_calibum(hObject, eventdata, handles);

% UIWAIT makes TileCollectorUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TileCollectorUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popup_objectives.
function popup_objectives_Callback(hObject, eventdata, handles)
    contents = cellstr(hObject.String);
    Value = hObject.Value;
    SelectedObjective = contents{Value};

    logentry(['Setting Magnification to ' SelectedObjective '.']);

    scope_set_nosepiece(handles.scope, Value);
    
    mag = regexp(SelectedObjective, '(\d*)X', 'tokens');
    mag = mag{1}{1};
    handles.mag = str2double(mag);   
    guidata(hObject, handles);
        
    update_calibum(hObject, eventdata, handles);

    


% --- Executes during object creation, after setting all properties.
function popup_objectives_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in popup_opticalpaths.
function popup_opticalpaths_Callback(hObject, eventdata, handles)
    contents = cellstr(hObject.String);
    Value = hObject.Value;
    SelectedOpticalPath = contents{Value};

    logentry(['Setting Optical Path to ' SelectedOpticalPath '.']);

    scope_set_op_path(handles.scope, Value);


% --- Executes during object creation, after setting all properties.
function popup_opticalpaths_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on selection change in popup_filtercubes.
function popup_filtercubes_Callback(hObject, eventdata, handles)
    contents = cellstr(hObject.String);
    Value = hObject.Value;
    SelectedCube = contents{Value};

    logentry(['Setting Cube to ' SelectedCube '.']);

    scope_set_filterblock(handles.scope, Value);


% --- Executes during object creation, after setting all properties.
function popup_filtercubes_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function edit_focus_Callback(hObject, eventdata, handles)
    NewFocus = round(str2num(get(hObject,'String')));

    logentry(['Setting focus to ' num2str(NewFocus, '%i') '.']);

    scope_set_focus(handles.scope, NewFocus);
    ArrivedFocus = scope_get_focus(handles.scope);
    
    hObject.String = num2str(ArrivedFocus);
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_focus_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in btn_Autofocus.
function btn_Autofocus_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Autofocus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popup_multiplier.
function popup_multiplier_Callback(hObject, eventdata, handles)
% hObject    handle to popup_multiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_multiplier contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_multiplier
    contents = cellstr(hObject.String);
    Value = hObject.Value;
    mult = contents{Value};    

    handles.mult = str2double(mult); 
    
    update_calibum(hObject, eventdata, handles);
    guidata(hObject, handles);
    

% --- Executes during object creation, after setting all properties.
function popup_multiplier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_multiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Xmin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Xmin as text
%        str2double(get(hObject,'String')) returns contents of edit_Xmin as a double


% --- Executes during object creation, after setting all properties.
function edit_Xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Ymin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Ymin as text
%        str2double(get(hObject,'String')) returns contents of edit_Ymin as a double


% --- Executes during object creation, after setting all properties.
function edit_Ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Xmax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Xmax as text
%        str2double(get(hObject,'String')) returns contents of edit_Xmax as a double


% --- Executes during object creation, after setting all properties.
function edit_Xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Ymax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Ymax as text
%        str2double(get(hObject,'String')) returns contents of edit_Ymax as a double


% --- Executes during object creation, after setting all properties.
function edit_Ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_collectmosaic.
function btn_collectmosaic_Callback(hObject, eventdata, handles)
% hObject    handle to btn_collectmosaic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ludl = handles.ludl;
calibum = handles.calibum;
exptime = str2double(handles.edit_exptime.String);

Ymin = str2double(handles.edit_Ymin.String);
Ymax = str2double(handles.edit_Ymax.String);
Xmin = str2double(handles.edit_Xmin.String);
Xmax = str2double(handles.edit_Xmax.String);

overlap = str2double(handles.edit_overlapfactor.String);

if handles.checkbox_saveTF.Value
    mosaicfile = handles.edit_mosaicfilename.String;
else
    mosaicfile = '';
end

if isfield(handles, 'previewFigure') && isvalid(handles.previewFigure)
    close(handles.previewFigure);
end

m = tc_manualmosaic(ludl, exptime, calibum, [Xmin Xmax], [Ymin Ymax], overlap, mosaicfile);

if handles.checkbox_plotmosaicTF.Value
    tc_show_mosaic(m);
end

handles.mosaic = m;

function edit_overlapfactor_Callback(hObject, eventdata, handles)
% hObject    handle to edit_overlapfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_overlapfactor as text
%        str2double(get(hObject,'String')) returns contents of edit_overlapfactor as a double


% --- Executes during object creation, after setting all properties.
function edit_overlapfactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_overlapfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_plotmosaicTF.
function checkbox_plotmosaicTF_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plotmosaicTF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_plotmosaicTF



function edit_mosaicfilename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mosaicfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mosaicfilename as text
%        str2double(get(hObject,'String')) returns contents of edit_mosaicfilename as a double


% --- Executes during object creation, after setting all properties.
function edit_mosaicfilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mosaicfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_saveTF.
function checkbox_saveTF_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_saveTF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_saveTF



function edit_calibum_Callback(hObject, eventdata, handles)
% hObject    handle to edit_calibum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_calibum as text
%        str2double(get(hObject,'String')) returns contents of edit_calibum as a double


% --- Executes during object creation, after setting all properties.
function edit_calibum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_calibum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_exptime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_exptime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_exptime as text
%        str2double(get(hObject,'String')) returns contents of edit_exptime as a double


% --- Executes during object creation, after setting all properties.
function edit_exptime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_exptime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_showpreview.
function pushbutton_showpreview_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_showpreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if ~isfield(handles, 'previewFigure') || ~isvalid(handles.previewFigure)
        handles.previewFigure = vid_impreview;
        guidata(hObject, handles);
    end
    
    
function update_calibum(hObject, eventdata, handles)
    mag = handles.mag;
    mult = handles.mult;
    
    scales = handles.Instrument.Scope.ScalingFactors;
    
    handles.calibum = scales.MicronsPerPixel( scales.Magnification == mag & ...
                                              scales.Multiplier == mult );
    handles.edit_calibum.String = num2str(handles.calibum);                                                                                    
    guidata(hObject, handles);
