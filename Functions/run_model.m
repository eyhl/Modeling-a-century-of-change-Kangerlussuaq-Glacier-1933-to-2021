% Main script for running Kangerlussuaq glacier model for period 1900-2020
function [md] = run_model(config_name, plotting_flag)
    % if ~exist('md','var')
    %     % third parameter does not exist, so default it to something
    %      md = md;
    % end
    if nargin < 2
        plotting_flag = false;
    end

    % for plotting:
    xl = [4.578, 5.132]*1e5;
    yl = [-2.3239, -2.2563]*1e6;
    
    % read config file
    config = readtable(append('Configs/', config_name), "TextType", "string");

    %% 0 Set parameters
    try
        steps = str2num(config.steps);
    catch
        steps = config.steps; % in case of single step
    end
    
    % model start time
    start_time = config.start_time;
    final_time = config.final_time;
    ice_temp_offset = config.ice_temp_offset;
    friction_law = config.friction_law;
    output_frequency = config.output_frequency;

    % Inversion parameters
    if strcmp(config.friction_law, 'budd')
        cs_min = 0.01; %config.cs_min;
        cs_max = 1e4; %config.cs_max;
        budd_coeff = [config.cf_weights_1, config.cf_weights_2, config.cf_weights_3];
        display_coefs = num2str(budd_coeff);
    elseif strcmp(config.friction_law, 'regcoulomb')
        cs_min = 0.01; %config.cs_min;
        cs_max = 1e4; %config.cs_max;
        regcoulomb_coeff = [config.cf_weights_1, config.cf_weights_2, config.cf_weights_3, config.cf_weights_4];
        display_coefs = num2str(regcoulomb_coeff);
    elseif strcmp(config.friction_law, 'schoof')
        cs_min = 0.01; %config.cs_min;
        cs_max = 1e4; %config.cs_max;
        schoof_coeff = [config.cf_weights_1, config.cf_weights_2, config.cf_weights_3, config.cf_weights_4];
        display_coefs = num2str(schoof_coeff);
    elseif strcmp(config.friction_law, 'weertman')
        cs_min = 0.01; %config.cs_min;
        cs_max = 1e4; %config.cs_max;
        weertman_coeff = [config.cf_weights_1, config.cf_weights_2, config.cf_weights_3];;
        display_coefs = num2str(weertman_coeff);
    end

    % reference smb time
    ref_smb_start_time = 1972; % don't change
    ref_smb_final_time = 1989; % don't change

    % temperature field extrapolation offset, qualitative
    add_constant = 2.5;

    % Shape file and model name
    glacier_name = convertStringsToChars(config.glacier_name);
    prefix = append(glacier_name, '_'); 

    % Relevant data paths
    front_shp_file = 'Data/shape/fronts/merged_fronts/merged_fronts.shp';

    if strcmp(config.smb_name, "box")
        smb_file = 'Data/smb/box_smb/Box_Greenland_SMB_monthly_1840-2012_5km_cal_ver20141007.nc';
    else
        smb_file = 'Data/smb/racmo/';
    end

    % Surface velocity data
    data_vx = 'Data/measure_multi_year_v1/greenland_vel_mosaic250_vx_v1.tif';
    data_vy = 'Data/measure_multi_year_v1/greenland_vel_mosaic250_vy_v1.tif';

    run_lia_parameterisation = 1; %TODO: put into config

    % Organizer
    append(glacier_name, '_')
    org = organizer('repository', ['./Models'], 'prefix', prefix, 'steps', steps); 
    
    fprintf("Running model from %d to %d, with:\n", start_time, final_time);
    fprintf(" - algorithm steps: [%s]\n", num2str(steps));
    fprintf(" - friction law: %s\n", config.friction_law);
    fprintf("   - inversion coefficients: %s\n", display_coefs);
    fprintf("   - [CS_min, CS_max] = [%.3g, %.3g]\n", cs_min, cs_max);

    clear steps;

    cluster=generic('name', oshostname(), 'np', 30);
    waitonlock = Inf;

    %% 1 Mesh: setup and refine
    if perform(org, 'mesh')
        % domain of interest
        % domain = ['Exp/domain/' 'Kangerlussuaq_new' '.exp'];
        domain = ['Exp/domain/' 'Kangerlussuaq_full_basin_no_sides' '.exp'];

        % Creates, refines and saves mesh in md
        check_mesh = false;
        md = meshing(domain, data_vx, data_vy, check_mesh);
        savemodel(org, md);
        if plotting_flag
            plotmodel(md, 'data', 'mesh'); exportgraphics(gcf, "mesh.png")
        end
    end

    %% 2 Parameterisation: Default setup with .par file
    if perform(org, 'param')
        md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'mesh.mat']);

        md = setflowequation(md,'SSA','all');
        md = setmask(md,'','');

        md = parameterize(md, 'ParameterFiles/inversion_present_day.par');

        % Set temperature field
        disp("Setting ISMIP6 temperature...")
        md = interpTemperature(md);

        disp("Extrapolating temperature into fjord...")
        M = 1; % polynomial order
        md = temperature_correlation_model(md, M, add_constant, plotting_flag);
        md.materials.rheology_B = cuffey(md.miscellaneous.dummy.temperature_field) .* ones(md.mesh.numberofvertices, 1);  % temperature field is already in Kelvin
        
        if plotting_flag
            figure(67);
            plotmodel(md, 'data', md.materials.rheology_B, 'title', 'Rheology B', ...
            'colorbar', 'off', 'xtick', [], 'ytick', [], 'xlim#all', xl, 'ylim#all', yl, 'figure', 21); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "rheology_B_extrapolated.png")
        end
        md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
        md.cluster = cluster;
        savemodel(org, md);
    end

    %% 3 Forcings: Interpolate SMB
    if perform(org, 'smb')
        md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'param.mat']);

        if strcmp(config.smb_name, "box")
            md = interpolate_box_smb(md, start_time, final_time, smb_file);
        else
            the_files = dir(fullfile(smb_file, '*.nc'));
            %TODO: CANNOT HANDLE ONLY PRE 1958 SELECTION (cat() reconstruct_racmo should be tested for this)
            % reconstruct racmo if year<1958
            if start_time < 1958 || final_time < 1958
                disp("post 1958 - interpolating racmo")
                md = interpolate_racmo_smb(md, 1958, final_time, the_files); % -1 to run to end 2021
                disp("pre 1958 - reconstructing racmo")
                md = reconstruct_racmo(md, start_time, final_time, ref_smb_start_time, ref_smb_final_time);
            else
                disp("post 1958 - interpolating racmo")
                md = interpolate_racmo_smb(md, start_time, final_time, the_files);
            end
        end 
        savemodel(org, md);
    end

    %% 4 Friction law setup: Budd %TODO: add friction step with friction_law condition inside instead.
    if perform(org, 'budd')
        md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'smb.mat']);
        md = solve_stressbalance_budd(md, budd_coeff, cs_min, cs_max);
        savemodel(org, md);

        if plotting_flag
            figure(1);
            plotmodel(md, 'data', md.friction.coefficient, 'title', 'Budd Friction Law, Coefficient', ...
            'colorbar', 'off', 'xtick', [], 'ytick', [], 'xlim#all', xl, 'ylim#all', yl, 'figure', 31); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "budd_friction.png")

            figure(2);
            plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, 'title', 'Budd Friction Law, Velocity', ...
            'colorbar', 'off', 'xtick', [], 'ytick', [], 'xlim#all', xl, 'ylim#all', yl, 'figure', 32); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "budd_sb_vel.png")
        end
        
    end

    %% 5 Friction law setup: Weertman
    if perform(org, 'weertman')

        md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'smb.mat']);
        md = solve_stressbalance_weert(md, weertman_coeff, cs_min, cs_max);
        savemodel(org, md);

        if plotting_flag
            figure(1);
            plotmodel(md, 'data', md.friction.C, 'title', 'Budd Friction Law, Coefficient', ...
            'colorbar', 'off', 'xtick', [], 'ytick', [], 'xlim#all', xl, 'ylim#all', yl, 'figure', 31); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "budd_friction.png")

            figure(2);
            plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, 'title', 'Budd Friction Law, Velocity', ...
            'colorbar', 'off', 'xtick', [], 'ytick', [], 'xlim#all', xl, 'ylim#all', yl, 'figure', 32); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "budd_sb_vel.png")
        end
        
    end

    %% 6 Friction law setup: Schoof
    if perform(org, 'schoof')
        friction_law = 'schoof';
        md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'budd.mat']);
        % md = loadmodel('Models/accepted_models/Model_kangerlussuaq_budd.mat');
        % md = loadmodel('/data/eigil/work/lia_kq/Models/kg_budd_lia.mat');

        % md = loadmodel('Models/kg_budd_lia.mat');
        md.cluster = cluster;
        md.verbose.solution = 1;

        % fast solver
        md.toolkits.DefaultAnalysis=bcgslbjacobioptions();
        md = budd2schoof(md, schoof_coeff, cs_min, cs_max);
        
        savemodel(org, md);
        if plotting_flag
            plotmodel(md, 'data', md.friction.C, 'title', 'Schoof Friction Law, Coefficient', ...
            'colorbar', 'off', 'xtick', [], 'ytick', [], 'figure', 41, 'xlim#all', xl, 'ylim#all', yl); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "schoof_friction.png")

            plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, 'title', 'Schoof Friction Law, Velocity', ...
            'colorbar', 'off', 'xtick', [], 'ytick', [], 'figure', 42, 'xlim#all', xl, 'ylim#all', yl); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "schoof_sb_vel.png")
        end
    end

    %% 7 Parameterize LIA, extrapolate friction coefficient to LIA front
    if perform(org, 'lia')
        offset = true;
        if strcmp(config.friction_law, 'schoof')
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'schoof.mat']);
            M = config.polynomial_order; % polynomial order
        elseif strcmp(config.friction_law, 'budd')
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'budd.mat']);
            M = config.polynomial_order; % polynomial order
            % md = loadmodel('/data/eigil/work/lia_kq/Models/kg_budd_lia.mat');
        elseif strcmp(config.friction_law, 'weertman')
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'weertman.mat']);
            M = config.polynomial_order; % polynomial order
        else
            warning("Friction law not implemented")
        end
        % STATISTICS FOR BUDD LIA INIT
        % mean(mdb.results.StressbalanceSolution.Vel) = 715.5533
        % std(mdb.results.StressbalanceSolution.Vel) = 1.5335e+03
        % max(mdb.results.StressbalanceSolution.Vel) = 6.9819e+03
        % mean(log(1 + mdb.results.StressbalanceSolution.Vel)/log(10)) = 2.0830
        % std(log(1 + mdb.results.StressbalanceSolution.Vel)/log(10)) = 0.8722
        % max(log(1 + mdb.results.StressbalanceSolution.Vel)/log(10)) = 3.8440

        disp("Parameterizing to LIA initial state")
        md = parameterize(md, 'ParameterFiles/transient_lia.par');
        validate_flag = false; % TODO: move into config

        disp("Extrapolating friction coefficient...")
        if strcmp(config.friction_extrapolation, "bed_correlation")
            % save M for reference
            md.miscellaneous.dummy.bed_corr_polynomial_order = M;

            disp("Extrapolating friction coefficient correlated polynomially with bed topography")
            [extrapolated_friction, extrapolated_pos, ~] = friction_correlation_model(md, cs_min, M, config.friction_law, validate_flag);
        elseif strcmp(config.friction_extrapolation, 'exponential_correlation')
            [extrapolated_friction, extrapolated_pos, ~] = friction_exponential_model(md, cs_min, friction_law, validate_flag);
 
        elseif strcmp(config.friction_extrapolation, "constant")
            disp("Extrapolating friction coefficient using constant value")
            [extrapolated_friction, extrapolated_pos, ~] = friction_constant_model(md, cs_min, config.friction_law, validate_flag);
        else
            warning("Invalid extrapolation method from config file. Choose random_field, linear or constant")
        end

        % set values under cs min to cs min
        extrapolated_friction(extrapolated_friction <= cs_min) = cs_min;
        
        % OFFSET CORRECT AND SAVE IN MD: 
        %TODO: MOVE THIS LOGIC INTO CREATE_CONFIG.M FUNCTION OR CREATE SEPERATE FUNCTION.
        if strcmp(config.friction_law, 'budd')
            if offset
                disp('Offset correction')
                if strcmp(config.friction_extrapolation, "bed_correlation")
                    % offset = median(md.friction.coefficient) / 5;
                    offset = 2;
                    md.friction.coefficient(extrapolated_pos) = extrapolated_friction * offset;
                elseif strcmp(config.friction_extrapolation, "constant")
                    offset = 25;
                    md.friction.coefficient(extrapolated_pos) = offset;
                end
            else
                md.friction.coefficient(extrapolated_pos) = extrapolated_friction;
            end
            % md.friction.coefficient(pos_rocks) = cs_max;
            md.friction.coefficient(md.mask.ocean_levelset<0) = cs_min; 
            friction_field = md.friction.coefficient;

        elseif strcmp(config.friction_law, 'weertman')
            if offset
                disp('Offset correction')
                if strcmp(config.friction_extrapolation, "bed_correlation")
                    offset = 1.0;
                    md.friction.C(extrapolated_pos) = extrapolated_friction * offset;
                elseif strcmp(config.friction_extrapolation, "constant")
                    offset = 2350;
                    md.friction.C(extrapolated_pos) = offset;
                end
            else
                md.friction.C(extrapolated_pos) = extrapolated_friction;
            end
            % md.friction.coefficient(pos_rocks) = cs_max;
            md.friction.C(md.mask.ocean_levelset<0) = cs_min; 
            friction_field = md.friction.C;

        elseif strcmp(config.friction_law, 'schoof')
            if offset
                disp('Offset correction')
                if strcmp(config.friction_extrapolation, "bed_correlation")
                    % offset = median(md.friction.C) / 10;
                    offset = 1.5;
                    md.friction.C(extrapolated_pos) = extrapolated_friction * offset;
                elseif strcmp(config.friction_extrapolation, "constant")
                    offset = 2000;
                    md.friction.C(extrapolated_pos) = offset;
                end
            else
                md.friction.C(extrapolated_pos) = extrapolated_friction;
            end
            % md.friction.C(pos_rocks) = cs_max;
            md.friction.C(md.mask.ocean_levelset<0) = cs_min; 
            friction_field = md.friction.C;
            
        else
            warning('Friction law not recignised, choose schoof or budd')
        end

        if plotting_flag
            plotmodel(md, 'data', friction_field, 'title', 'Friction Coefficient', ...
            'colorbar', 'off', 'xtick', [], 'ytick', [], 'xlim#all', xl, 'ylim#all', yl, 'figure', 61); 
            set(gca,'fontsize',12);
            set(colorbar,'visible','off')
            h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
            colormap('turbo'); 
            exportgraphics(gcf, "budd_friction_extrapolated.png")
        end

        % CHECK INITIAL STATE:
        md.inversion.iscontrol = 0;
        md = solve(md, 'sb');
        plotmodel(md, 'data', friction_field, ...
                      'data', log(friction_field)./log(10), ...
                      'data', md.results.StressbalanceSolution.Vel, ...
                      'title', 'Initial state, FC and Vel', 'caxis#1', [0 median(friction_field)], ...
                      'xtick', [], 'ytick', [], 'xlim#all', xl, 'ylim#all', yl, 'figure', 62); 
        set(gca,'fontsize',12);
        colormap('turbo'); 
        exportgraphics(gcf, "initial_state.png")

        savemodel(org, md);
    end

    %% 8 Initialise: Setup and load calving fronts
    if perform(org, 'fronts')
        if run_lia_parameterisation == 1
            disp("Using LIA initial conditoins")
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'lia.mat']);

        else
            disp("Not using LIA initial conditions")
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'friction.mat']);
        end

        md = fronts_init(md, output_frequency, start_time, final_time); % initialises fronts
        md = fronts_transient(md, front_shp_file); % loads front observations
        savemodel(org, md);
    end

    %% 9 Transient: setup & run
    if perform(org, 'transient')
        md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'fronts.mat']);

        % meltingrate
        timestamps = [md.timestepping.start_time, md.timestepping.final_time];
        md.frontalforcings.meltingrate=zeros(md.mesh.numberofvertices+1, numel(timestamps));
        md.frontalforcings.meltingrate(end, :) = timestamps;

        md.cluster = cluster;
        md.verbose.solution = 1;

        % fast solver
        md.toolkits.DefaultAnalysis=bcgslbjacobioptions();

        % for testing
        % md.timestepping.start_time = 1900;
        % md.timestepping.final_time = 1900.1;

        % fix front, option
        if config.control_run
            disp('-------------- CONTROL RUN --------------')
            md.transient.ismovingfront = 0;
        end

        % get output
        md.transient.requested_outputs={'default','IceVolume','IceVolumeAboveFloatation','GroundedArea','FloatingArea','TotalSmb'}; % {'default', 'IceVolume', 'IceVolumeAboveFloatation'}; %,'IceVolume','MaskIceLevelset', 'MaskOceanLevelset'};

        md.settings.waitonlock = waitonlock; % do not wait for complete
        disp('SOLVE')
        md=solve(md,'Transient','runtimename',false);
        disp('SAVE')
        savemodel(org, md);
    end
    %% end of script
end