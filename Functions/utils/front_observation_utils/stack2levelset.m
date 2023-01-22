function [md] = stack2levelset(md, front_shp_file)
    % set levelset in the format [fronts; times]
    disp("Running ExpToLevelSet(), might take a minute...")
    md.levelset.spclevelset = ExpToLevelSet(md.mesh.x, md.mesh.y, front_shp_file);

    % levelsets should be negative where there is ice. It is already negative for the InitLevelset, so skip that column
    md.levelset.spclevelset= -1 .* md.levelset.spclevelset;
end