function [md] = meshing(domain, data_vx, data_vy, check_mesh)
    % [A, R] = readgeoraster(data);
    % X_range = R.XWorldLimits(1):500:R.XWorldLimits(2);
    % Y_range = R.YWorldLimits(1):500:R.YWorldLimits(2);
 
    md=triangle(model, domain, 800);
    md.mesh.epsg=3413;

    % x and y has to be column vectors, and A and y axis has to be upside down wrt to real world
    % vel = InterpFromGridToMesh(X_range', Y_range', flipud(A), md.mesh.x, md.mesh.y, 0);
    [vel, ~, ~] = interpVelocity(md, data_vx, data_vy);

    % extend refinement to 1900 front position (larger than necessary to be sure)
    h = NaN * ones(md.mesh.numberofvertices, 1);
    indeces = ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/1900_refine_area.exp', 1);
    h(find(indeces)) = 350;

    % extend refinement to 1900 front position (larger than necessary to be sure)
    % h = NaN * ones(md.mesh.numberofvertices, 1);
    % indeces = ContourToNodes(md.mesh.x, md.mesh.y, 'Exp/thin_icebergs.exp', 1);
    % h(find(indeces)) = 1000;

    md=bamg(md, 'hmin', 350, 'hmax', 12000, 'field', vel ,'err', 3, 'hVertices', h);

    [md.mesh.lat,md.mesh.long]  = xy2ll(md.mesh.x,md.mesh.y,+1,45,70);

    
    if check_mesh
        plotmodel(md, 'data', 'mesh'); exportgraphics(gcf, 'md_mesh_refined.png');
    end
end