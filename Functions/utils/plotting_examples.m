function [] = investigation_plotting(name)
    %% Load model and check velocity fields set in .par
    % md = loadmodel(['/data/eigil/work/kangerlussuaq_learn/Models/kangerlussuaq_debug_friction_', name, '.mat']);

    %% Check initialisation
    check_init = false;
    if check_init
        md = loadmodel('/data/eigil/work/kangerlussuaq_learn/Models/Model_kangerlussuaq_param.mat');
        disp('Plotting Parameterization')
        plotmodel(md, 'data', md.inversion.vel_obs, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.inversion.vel_obs.png']);
        plotmodel(md, 'data', md.inversion.vx_obs, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.inversion.vx_obs.png']);
        plotmodel(md, 'data', md.inversion.vy_obs, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.inversion.vy_obs.png']);
        plotmodel(md, 'data', md.geometry.thickness); exportgraphics(gcf, [name, '_', 'md.geometry.thickness.png'])
    end

    %% Check StressBalance Solution
    check_stress = true;
    if check_stress
        md = loadmodel('/data/eigil/work/kangerlussuaq_learn/Models/Model_kangerlussuaq_friction.mat');
        disp('Plotting StressBalance Solution')
        % plotmodel(md, 'data', 'BC'); exportgraphics(gcf, [name, '_', 'bcs.png']);
        % plotmodel(md, 'data', 'boundaries'); exportgraphics(gcf, [name, '_', 'boundaries.png']);
        % plotmodel(md, 'data', 'icefront'); exportgraphics(gcf, [name, '_', 'icefront.png']);
        plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.StressbalanceSolution.Vel.png']);
        plotmodel(md, 'data', md.results.StressbalanceSolution.Vx, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.StressbalanceSolution.Vx.png']);
        plotmodel(md, 'data', md.results.StressbalanceSolution.Vy, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.StressbalanceSolution.Vy.png']);
        plotmodel(md, 'data', abs(md.results.StressbalanceSolution.Vel - md.inversion.vel_obs), 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.StressbalanceSolution.Vel_error.png']);
        plotmodel(md, 'data', abs(md.results.StressbalanceSolution.Vx - md.inversion.vx_obs), 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.StressbalanceSolution.Vx_error.png']);
        plotmodel(md, 'data', abs(md.results.StressbalanceSolution.Vy - md.inversion.vy_obs), 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.StressbalanceSolution.Vy_error.png']);
        plotmodel(md, 'data', md.results.StressbalanceSolution.FrictionCoefficient); exportgraphics(gcf, [name, '_', 'md.results.StressbalanceSolution.FrictionC.png']); 
        plotmodel(md, 'data', md.results.StressbalanceSolution.Pressure); exportgraphics(gcf, [name, '_', 'md.results.StressbalanceSolution.Pressure.png']); 
        plot(md.results.StressbalanceSolution.J); ylim([1e-3, 1e4]); set(gca, 'YScale', 'log'); grid; legend('101', '103', '501', '.'); exportgraphics(gcf, [name, '_', 'J.png']) 
    end

    %% Check transient solution
    check_transient = false;
    if check_transient
        md = loadmodel('/data/eigil/work/kangerlussuaq_learn/Models/Model_kangerlussuaq_transient.mat');
        plotmodel(md, 'data', md.results.TransientSolution(1).Vel, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.TransientSolution(1).Vel.png']);
        plotmodel(md, 'data', md.results.TransientSolution(end).Vel, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.TransientSolution(end).Vel.png']);
        plotmodel(md, 'data', md.results.TransientSolution(1).Thickness, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.TransientSolution(1).Thickness.png']);
        plotmodel(md, 'data', md.results.TransientSolution(end).Thickness, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.TransientSolution(end).Thickness.png']);
        % plotmodel(md, 'data', md.results.TransientSolution(1).CalvingCalvingrate, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.TransientSolution(1).CalvingCalvingrate.png']);
        % plotmodel(md, 'data', md.results.TransientSolution(end).CalvingCalvingrate, 'gridded', 1, 'levelset', md.mask.ice_levelset); exportgraphics(gcf, [name, '_', 'md.results.TransientSolution(end).CalvingCalvingrate.png']);
    end

    %% Check velocity data
    check_data = false;
    if check_data
        warning("Does not exist anymore: Data/nsidc_2006/greenland_vel_mosaic500_2006_2007_vv_v02.1.tif\n NSIDC data on local machine");
            [A, R] = readgeoraster(data);
            X_range = R.XWorldLimits(1):500:R.XWorldLimits(2);
            Y_range = R.YWorldLimits(1):500:R.YWorldLimits(2);

            % plot area of interest in velocity data
            imagesc(X_range(2000:2500), Y_range(3000:3500), A(3000:3500, 2000:2500)); 
            colorbar();
            exportgraphics(gcf, [name, '_', 'vel_nsidc.png']);
    end 

    %% Check meshing with nsidc data
    check_mesh = false;
    if check_mesh
        disp('Plotting mesh')
        % domain of interest
        domain = ['Exp/' 'Kangerlussuaq' '.exp'];
        % Surface velocity data
        data = 'Data/nsidc_2006/greenland_vel_mosaic500_2006_2007_vv_v02.1.tif';
        [A, R] = readgeoraster(data);
        X_range = R.XWorldLimits(1):500:R.XWorldLimits(2);
        Y_range = R.YWorldLimits(1):500:R.YWorldLimits(2);

        % plot area of interest in velocity data
        imagesc(X_range(2000:2500), Y_range(3000:3500), A(3000:3500, 2000:2500)); 
        colorbar();
        exportgraphics(gcf, [name, '_', 'vel_nsidc.png']);
        md=triangle(model, domain, 2000);
        md.mesh.epsg=3413;

        % x and y has to be column vectors, and A and y axis has to be upside down wrt to real world
        vel = InterpFromGridToMesh(X_range', Y_range', flipud(A), md.mesh.x, md.mesh.y, 0);
        scatter(md.mesh.x, md.mesh.y, 10, vel, 'filled'); colorbar(); exportgraphics(gcf, [name, '_', 'vel_mesh.png']);

        % adapt mesh and plot
        md=bamg(md, 'hmax', 8000, 'hmin', 1750, 'field', vel ,'err', 8);
        plotmodel(md, 'data', 'mesh'); exportgraphics(gcf, [name, '_', 'md_mesh_refined.png']);
        [md.mesh.lat,md.mesh.long]  = xy2ll(md.mesh.x,md.mesh.y,+1,45,70);
    end
end