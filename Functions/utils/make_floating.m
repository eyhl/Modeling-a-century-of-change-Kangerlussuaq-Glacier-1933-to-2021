function md = make_floating(md)
    md_inv = loadmodel('Models/KG_param.mat');

    %% set ice levelset corresponding to lia
    tmp_levelset = ExpToLevelSet(md.mesh.x, md.mesh.y, 'Exp/first_front/first_front.exp');
    pos = tmp_levelset(1:end-1) > 0;  % positive distances
    md.mask.ice_levelset(pos) = -1;

    disp('      reading LIA surface');
    % md.geometry.surface = interpLiaSurface(md.mesh.x, md.mesh.y);

    % make sure that ther is not ice outside levelset
    pos = tmp_levelset(1:end-1) < 0;
    md.geometry.surface(pos) = 0;
    % try to set exposed bedrock to 
    % mask = int8(interpBmGreenland(md.mesh.x, md.mesh.y, 'mask'));

    disp('      construct LIA thickness')
    md.geometry.thickness = md.geometry.surface - md.geometry.base;

    % floatation ratio TODO: REDUCE: 
    di = md.materials.rho_ice / md.materials.rho_water;
    float_ratio = 1 / di;

    % Get floating nodes. 
    % Note: from equation 6.57 (Greve & Blatter (2009)) we find that H/b <= rho_w / rho_i = 1.1
    condition1 =  md.geometry.thickness ./ abs(md.geometry.bed) <= float_ratio;
    condition2 = md.mask.ocean_levelset < 0;
    floating_ice = condition1 & condition2;
    pos = find(floating_ice);

    % % Apply floating condition see "Ralfe Greve, Heinz Blatter - Dynamics Of Ice Sheets And Glaciers (2009)"
    % rho * H = rho_w * (z_sl - h), where h is ice surface and z_sl is z wrt sea level. (eq. 6.44).
    md.geometry.thickness(pos) = 1 / (1 - 1/float_ratio) * md.geometry.surface(pos);
    md.geometry.base(pos) = md.geometry.surface(pos) - md.geometry.thickness(pos);

    pos_thin = find(md.geometry.thickness <= 10);
    md.geometry.thickness(pos_thin) = 10;

    md.geometry.surface = md.geometry.thickness + md.geometry.base;
    md.geometry.bed = md.geometry.base;
    md.geometry.bed(pos) = md_inv.geometry.base(pos); % md_inv.base = equals bedmachine

    grounded_ice = -floating_ice; % -1 for ocean nodes
    grounded_ice(grounded_ice==0) = 1; % 1 for non-ocean notes
    md.mask.ocean_levelset = grounded_ice;
    md.mask.ocean_levelset(md.mask.ice_levelset>0) = -1; % set all of the ocean to -1 as well

    %% Ice mask adjustment
    disp('   Adjusting ice mask');
    % Offset the mask by one element so that we don't end up with a cliff at the transition
    max_elem = max(md.mask.ice_levelset(md.mesh.elements), [], 2); % find max in each row
    pos = find(max_elem > 0);
    md.mask.ice_levelset(md.mesh.elements(pos, :)) = 1;

    % For the region where surface is NaN, set thickness to small value (consistency requires >0)
    pos = find((md.mask.ice_levelset < 0) .* (md.geometry.surface < 0));
    md.mask.ice_levelset(pos) = 1;
    pos = find((md.mask.ice_levelset < 0) .* (isnan(md.geometry.surface)));
    md.mask.ice_levelset(pos) = 1;
end