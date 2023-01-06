
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
load calfin: load_calfin()
extract most retreated front: extract_most_retreated_front()
check intersections between each shape with fjord polygon: find_shape_intersections()
order in time: reorder_shape()
order orientations: reorient_shape()
implement get_shape_stack() to return shape stack from shape input

implement get_autoterm_stack()
implement get_calfin_stack()
implement get_historic_stack()

combine stacks function combine_shape_stacks() -> single stack

connect stack to master shape: connect_stack2master_shape()

implement get_autoterm_historic_fronts()
implement get_calfin_historic_fronts()