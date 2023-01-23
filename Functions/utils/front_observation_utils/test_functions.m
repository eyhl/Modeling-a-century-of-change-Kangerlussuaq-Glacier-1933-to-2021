
%% Test load_autoterm
autoterm_file_path = "/data/eigil/work/lia_kq/Data/shape/fronts/AutoTerm/Termini/GID152.shp";
autoterm_shp = readgeotable(autoterm_file_path);
T = geotable2table(autoterm_shp,["Lat","Lon"]);
T1 = load_autoterm(autoterm_file_path);
check1 = max(size(T)) == max(size(T1));
check2 = true;
for i = 1:max(size(T))
    check2 = check2 * all(size(cell2mat(T1.Y(i))) == size(cell2mat(T1.Lon(i))));
    check2 = check2 * all(size(cell2mat(T1.X(i))) == size(cell2mat(T1.Lat(i))));
    if ~check2
        disp(i)
    end
end
if ~all([check1, check2])
    disp("Error in load autoterm")
    disp([check1, check2])
end


%% NEXT
% load calfin: load_calfin()
% meridian function S [56381,-3057938] N [56381,-981106]
extract most retreated front: extract_most_retreated_front()
% check intersections between each shape with fjord polygon: find_shape_intersections()
% order in time: reorder_shape()
order orientations: reorient_shape()
implement get_shape_stack() to return shape stack from shape input

implement get_autoterm_stack()
implement get_calfin_stack()
implement get_historic_stack()

combine stacks function combine_shape_stacks() -> single stack

connect stack to master shape: connect_stack2master_shape()

implement get_autoterm_historic_fronts(md, autoterm_path, historic_path, fjord_path, ice_levelset_domain_path)
            autoterm_stack = get_autoterm_stack(autoterm_path);
            historic_stack = get_historic_stack(historic_path);
            autoterm_historic_stack = combine_stacks({historic_stack, autoterm_stack}, {condition1, condition2});
            fjord = get_fjord_shape(calfin_path); % in if-statement I would like to provide my own
            ice_domain = load_ice_domain_from_shape(ice_path);
            stack = connect_stack2master_shape(autoterm_historic_stack, fjord, 'fjord');
            stack = connect_stack2master_shape(stack, ice_domain, 'ice_levelset');
            md = loadmodel(mesh.mat);
            md = stack2levelset(md, autoterm_historic_stack);
                convert2levelset(stack)
                    function: get decimal dates
                    use first front as initial
                    md should only have mesh or somthing simple
                ereturn md

implement get_calfin_historic_fronts(md)
            similar

remove stack2levelset, it is done in runme
add some unittest


% Implement test: compare heights of stacked tables
% >> height(at) + heigt(hi(condition_hi,:))
% Unrecognized function or variable 'heigt'.

% >> height(at) + height(hi(condition_hi,:))

% ans =

%         1574

% >> height(stack)

% ans =

%         1574