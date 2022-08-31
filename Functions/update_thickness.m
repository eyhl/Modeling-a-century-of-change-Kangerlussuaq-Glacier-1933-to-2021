function [md] = update_thickness(md, misfit, method)
    if strcmp(method, "global")
        correction = zeros(size(md.geometry.thickness));
        nodes_with_large_err = misfit >= 50;
        correction(nodes_with_large_err) = misfit(nodes_with_large_err);

        step_size = 2/3; 
        % avg_misfit_correction = mean(misfit, 'omitnan');
        % intended to leave out areas where I do not want to update the misfit anyways:
        % no_ice_areas = md.geometry.thickness(isnan(misfit));
        md.geometry.thickness = md.geometry.thickness - step_size * correction;
        md.geometry.surface = md.geometry.thickness + md.geometry.bed;

        pos=find(md.geometry.thickness <= 10);
        md.geometry.surface(pos) = md.geometry.base(pos) + 10; %Minimum thickness
        md.geometry.thickness = md.geometry.surface - md.geometry.bed;

        % set transient boundary spc thickness
        pos = find(md.mesh.vertexonboundary);
        md.masstransport.spcthickness(pos, 1) = md.geometry.thickness(pos);

    elseif strcmp(method, "sectional") %TODO: IMPLEMENT
        disp("Not implemted yet")
    end
end