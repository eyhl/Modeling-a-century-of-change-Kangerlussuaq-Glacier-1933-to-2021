function [md] = fronts_transient(md, front_shp_file)
    %% Setting up fronts in time
    % load front data
    CFcontour = front_shp_file;

    % spclevelset
    disp('Assigning Calving front');
    md.levelset.spclevelset=NaN(md.mesh.numberofvertices, 1);

    %TODO: Don't think this is necessary. Initial condition is from the geometry
    pos = find(md.mask.ice_levelset < 0); md.mask.ice_levelset(pos) = -1;
    pos = find(md.mask.ice_levelset > 0); md.mask.ice_levelset(pos) = +1;

    % set observed fronts in temporally
    initLevelset = reinitializelevelset(md, md.mask.ice_levelset);

    initLevelset = [initLevelset; md.timestepping.start_time];

    % set levelset in the format [fronts; times]
    dataLevelset = ExpToLevelSet(md.mesh.x, md.mesh.y, CFcontour);

    % load QualFlag from shape files and append to the end
    sdata = shpread(CFcontour);
    qflag = cell2mat({sdata.QualFlag});
    dataLevelset = [dataLevelset; qflag];

    % select fronts within simulation time. Not super precise (just starts at 1900.00), but not important on this 100 year timescale
    time_selection = ((dataLevelset(end-1, :) > md.timestepping.start_time) & (dataLevelset(end - 1, :) <= md.timestepping.final_time));

    % Take data within the simulation time
    unsorted_distance = dataLevelset(:, time_selection);

    % sort and find duplicate: 1st order: time(+), 2nd order: QualFlag(-)
    last_row_index = size(unsorted_distance, 1);

    % first sort wrt time then sort wrt to qflag (descending). Meaning that
    % unresolved sorts by time (duplicates) will be sorted by quality.
    % sortrows syntax is weird, but stuff in [] determines if order is ascending and such.
    distance = sortrows(unsorted_distance', [last_row_index - 1, -last_row_index])';

    % ia contains indeces for non-duplicates
    [~, ia] = unique(distance(last_row_index - 1, :));

    % remove duplicate with lower qualFlag, and remove qflag row
    distance = distance(1 : end-1, ia);

    md.levelset.spclevelset = [initLevelset, distance];

    % levelsets should be negative where there is ice. It is already negative for the InitLevelset, so skip that column
    md.levelset.spclevelset(1 : end - 1, 2 : end) = -1 .* md.levelset.spclevelset(1 : end - 1, 2 : end);

    % TODO: should this be included?
    % % settings for the levelset method
    % md.levelset.reinit_frequency = 1;
    % md.levelset.stabilization = 2;
end