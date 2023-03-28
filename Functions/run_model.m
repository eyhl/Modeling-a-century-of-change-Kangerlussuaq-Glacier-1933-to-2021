% Main script for running Kangerlussuaq glacier model for period 1900-2020
function [md] = run_model(config_name, plotting_flag)
    % if ~exist('md','var')
    %     % third parameter does not exist, so default it to something
    %      md = md;
    % end
    if isempty(strfind(config_name, '.csv'))
        config_name = [config_name, '.csv'];
    end
    
    if nargin < 2
        plotting_flag = false;
    end

    % for plotting:
    xl = [4.578, 5.132]*1e5;
    yl = [-2.3239, -2.2563]*1e6;

    base_path = '/data/eigil/work/lia_kq/';
    
    % read config file
    config = readtable(fullfile(base_path, 'Configs/', config_name), "TextType", "string");

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
    lia_friction_offset = config.lia_friction_offset;
    friction_law = config.friction_law;
    output_frequency = config.output_frequency;
    velocity_exponent = config.velocity_exponent;

    % Inversion parameters
    if strcmp(config.friction_law, 'budd')
        cs_min = config.cs_min;
        cs_max = config.cs_max;
        budd_coeff = [config.cf_weights_1, config.cf_weights_2, config.cf_weights_3];
        display_coefs = num2str(budd_coeff);
    elseif strcmp(config.friction_law, 'budd_plastic')
        cs_min = config.cs_min;
        cs_max = config.cs_max;
        budd_plastic_coeff = [config.cf_weights_1, config.cf_weights_2, config.cf_weights_3];
        display_coefs = num2str(budd_plastic_coeff);
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
        weertman_coeff = [config.cf_weights_1, config.cf_weights_2, config.cf_weights_3];
        display_coefs = num2str(weertman_coeff);
    else
        disp('No friction law selected')
        cs_min = config.cs_min;
        cs_max = config.cs_max;
        display_coefs = num2str([config.cf_weights_1, config.cf_weights_2, config.cf_weights_3]);
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
    front_shp_file = convertStringsToChars(config.front_observation_path); %'Data/shape/fronts/merged_fronts/merged_fronts.shp';

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
    org = organizer('repository', fullfile(base_path, 'Models'), 'prefix', prefix, 'steps', steps); 
    
    fprintf("Running model from %d to %d, with:\n", start_time, final_time);
    fprintf(" - algorithm steps: [%s]\n", num2str(steps));
    fprintf(" - friction law: %s\n", config.friction_law);
    fprintf("   - inversion coefficients: %s\n", display_coefs);
    fprintf("   - [CS_min, CS_max] = [%.3g, %.3g]\n", cs_min, cs_max);
    fprintf("   - Velocity exponent = %.3g\n", velocity_exponent);
    fprintf("   - LIA friction factor = %.3g\n", lia_friction_offset);

    clear steps;

    cluster=generic('name', oshostname(), 'np', 30);
    waitonlock = Inf;

    %% 1 Mesh: setup and refine
    if perform(org, 'mesh')
        % domain of interest
        % domain = ['Exp/domain/' 'Kangerlussuaq_new' '.exp'];
        domain = ['Exp/domain/' 'Kangerlussuaq_full_basin_no_sides_copy' '.exp'];

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
        if ice_temp_offset ~= 0
            fprintf("NOTICE!: Offsetting temperature by %d...\n", ice_temp_offset);
            md.miscellaneous.dummy.temperature_field = md.miscellaneous.dummy.temperature_field + ice_temp_offset;
        end
        md.materials.rheology_B = cuffey(md.miscellaneous.dummy.temperature_field) .* ones(md.mesh.numberofvertices, 1);  % temperature field is already in Kelvin, multiplying with ones in case of scalar temperature field

        % add damage for shear margin
		if config.add_damage == 1 % change enhancement factor by large shear stress area
            disp(['Add damage to shear margin, Glen enhancement = 6']);
            md_ss = loadmodel('/data/eigil/work/lia_kq/Models/KG_budd_steady_state_50yr.mat');
			minEffStrain = 1;
			maxEffStrain = 3;
			md=mechanicalproperties(md,md.inversion.vx_obs,md.inversion.vy_obs);
            margin1 = md_ss.results.strainrate.effectivevalue < maxEffStrain & md_ss.results.strainrate.effectivevalue > minEffStrain;
            margin2 = md.results.strainrate.effectivevalue < maxEffStrain & md.results.strainrate.effectivevalue > minEffStrain;    
            % margins_pos = find();
            margins_pos=md.mesh.elements(margin1 | margin2);

			damage = ones(md.mesh.numberofvertices,1);
			damage(margins_pos) = 6; % from S. Cook 2021 https://doi.org/10.1017/jog.2021.109, who got it from somewhere else, which is a little more obscure.
            %disp(size(damage))
            %disp(size(md.materials.rheology_B))
			md.materials.rheology_B = 1 ./ ((damage).^(1/3)) .* md.materials.rheology_B;
		elseif (config.add_damage == 0)
			disp([' No damage to shear margin']);
		else
			error('Unknown damage type');
		end

        
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

         % ------ Load smb if already processed
        if isfile(['/data/eigil/work/lia_kq/Models/', prefix, 'smb.mat'])
            disp("Loading SMB from previous processing...")
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'param.mat']);
            md_smb = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'smb.mat']);
            if md.mesh.numberofelements ~= md_smb.mesh.numberofelements
                disp("Error mesh is different size in the two models")
            end
            md.smb.mass_balance = md_smb.smb.mass_balance;

        % ------ Compute smb
        else
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'param.mat']);
            disp("SMB processing in progress...")

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
        end
        savemodel(org, md);
    end

    %% 4 Friction law setup: Budd %TODO: add friction step with friction_law condition inside instead.
    if perform(org, 'budd')
        md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'smb.mat']);
        % pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/ice_at_fjord_sides.exp', 2));
        % md.mask.ice_levelset(pos) = 1;
        md = solve_stressbalance_budd(md, budd_coeff, cs_min, cs_max, velocity_exponent);
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

    %% 5 Friction law setup: Budd Plastic %TODO: add friction step with friction_law condition inside instead.
    if perform(org, 'budd_plastic')
        md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'budd_plastic copy 5.mat']);
        %md.friction.coefficient = rescale(md.friction.coefficient, 0.05, 2);
        md = solve_stressbalance_budd(md, budd_plastic_coeff, cs_min, cs_max, velocity_exponent);
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

    %% 6 Friction law setup: Weertman
    if perform(org, 'weertman')

        md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'smb.mat']);
        md = solve_stressbalance_weert(md, weertman_coeff, cs_min, cs_max);
        savemodel(org, md);

        if plotting_flag
            figure(1);
            plotmodel(md, 'data', md.friction.C, 'title', 'Friction Law, Coefficient', ...
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

    %% 7 Friction law setup: Schoof
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
    
    %% 8 Parameterize LIA initial conditions
    if perform(org, 'lia')
        offset = logical(lia_friction_offset);
        if strcmp(config.friction_law, 'budd')
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'budd.mat']);
            M = config.polynomial_order; % polynomial order
            extrapolated_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_slim_extend.exp', 2));

            disp("Extrapolating friction coefficient...")
            if strcmp(config.friction_extrapolation, "bed_correlation")
                % save M for reference
                md.miscellaneous.dummy.bed_corr_polynomial_order = M;
    
                disp("Extrapolating friction coefficient with polynomial bed topography CORRELATION")
                [extrapolated_friction, ~, ~] = friction_correlation_model(md, cs_min, M, config.friction_law);

            elseif strcmp(config.friction_extrapolation, "constant")
                disp("Extrapolating friction coefficient using CONSTANT value")
                [extrapolated_friction, ~, ~] = friction_constant_model(md, cs_min, config.friction_law);
            elseif strcmp(config.friction_extrapolation, "pollard")
                disp("Extrapolating friction coefficient using POLLARD inversion")

                md_pollard = loadmodel('/data/eigil/work/lia_kq/pollard_budd.mat');
                extrapolated_friction = md_pollard.friction.coefficient(extrapolated_pos);
                extrapolated_friction(extrapolated_friction <= cs_min) = cs_min;

            end
            
            md.friction.coefficient(extrapolated_pos) = extrapolated_friction;
            if ~strcmp(config.friction_extrapolation, "pollard")
                % set values under cs min to cs min
                extrapolated_friction(extrapolated_friction <= cs_min) = cs_min;
            end
            
            if offset
                disp('Offset correction')
                if strcmp(config.friction_extrapolation, "bed_correlation")
                    % offset = median(md.friction.coefficient) / 5;
                    offset = lia_friction_offset; % budd origninal
                    md.friction.coefficient(extrapolated_pos) = extrapolated_friction * offset;
                elseif strcmp(config.friction_extrapolation, "constant")
                    offset = lia_friction_offset;
                    md.friction.coefficient(extrapolated_pos) = offset;
                end
            end
            % md.friction.coefficient(pos_rocks) = cs_max;
            % md.friction.coefficient(md.mask.ocean_levelset<0) = cs_min; 

            
            friction_field = md.friction.coefficient;

        
        elseif strcmp(config.friction_law, 'budd_plastic')
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'budd_plastic.mat']);
            M = config.polynomial_order; % polynomial order
            extrapolated_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_slim_extend.exp', 2));

            disp("Extrapolating friction coefficient...")
            if strcmp(config.friction_extrapolation, "bed_correlation")
                % save M for reference
                md.miscellaneous.dummy.bed_corr_polynomial_order = M;
    
                disp("Extrapolating friction coefficient correlated polynomially with bed topography")
                [extrapolated_friction, ~, ~] = friction_correlation_model(md, cs_min, M, config.friction_law, false);

            elseif strcmp(config.friction_extrapolation, "constant")
                disp("Extrapolating friction coefficient using constant value")
                [extrapolated_friction, ~, ~] = friction_constant_model(md, cs_min, config.friction_law);

            elseif strcmp(config.friction_extrapolation, "from_budd")
                disp("Using Budd bed correlation to extrapolate")
                mdb = loadmodel("/data/eigil/work/lia_kq/Results/lia_correction2-18-Mar-2023/KG_transient.mat");
                extrapolated_friction = mdb.friction.coefficient(extrapolated_pos) .* (mdb.results.StressbalanceSolution.Vel(extrapolated_pos)./md.constants.yts).^(2./5);                           
                extrapolated_friction = min(extrapolated_friction, 10);              
                md.friction.coefficient(extrapolated_pos) = extrapolated_friction;
            end

            if ~strcmp(config.friction_extrapolation, "pollard")
                % set values under cs min to cs min
                extrapolated_friction(extrapolated_friction <= cs_min) = cs_min;
            end

            if offset
                disp('Offset correction')
                if strcmp(config.friction_extrapolation, "bed_correlation")
                    % offset = median(md.friction.coefficient) / 5;
                    offset = lia_friction_offset;
                    md.friction.coefficient(extrapolated_pos) = extrapolated_friction * offset;
                elseif strcmp(config.friction_extrapolation, "constant")
                    offset = lia_friction_offset;
                    md.friction.coefficient(extrapolated_pos) = offset;
                end
            else
                md.friction.coefficient(extrapolated_pos) = extrapolated_friction;
            end
            % md.friction.coefficient(pos_rocks) = cs_max;
            % md.friction.coefficient(md.mask.ocean_levelset<0) = cs_min; 

            
            friction_field = md.friction.coefficient;

            % --- Retrieve from budd solution ---
            % extrapolated_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_slim_extend.exp', 2));
            % % md = loadmodel('/data/eigil/work/lia_kq/Models/kg_budd_lia.mat');
            % disp("Extrapolating friction coefficient...")
            % md_budd_lia = loadmodel('Models/KG_budd_lia.mat');
            % scaled_friction = md_budd_lia.friction.coefficient .* (md_budd_lia.results.StressbalanceSolution.Vel./md_budd_lia.constants.yts).^(2./5);
            % scaled_friction = rescale(scaled_friction, min(md.friction.coefficient), max(md.friction.coefficient));
            % scaled_friction = InterpFromMeshToMesh2d(md_budd_lia.mesh.elements, md_budd_lia.mesh.x, md_budd_lia.mesh.y, scaled_friction, md.mesh.x(extrapolated_pos), md.mesh.y(extrapolated_pos));
            % md.friction.coefficient(extrapolated_pos) = scaled_friction;
            % friction_field = md.friction.coefficient;
        else
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'budd.mat']);
        end
        disp("Parameterizing to LIA initial state")
        md = parameterize(md, 'ParameterFiles/transient_lia.par');

        disp("Extrapolate Friction Coefficient")
    
    % %% 8 Parameterize LIA, extrapolate friction coefficient to LIA front
    % if perform(org, 'lia')
    %     offset = true;
    %     if strcmp(config.friction_law, 'schoof')
    %         md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'schoof.mat']);
    %         M = config.polynomial_order; % polynomial order
    %     elseif strcmp(config.friction_law, 'budd')
    %         md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'budd.mat']);
    %         M = config.polynomial_order; % polynomial order
    %         % md = loadmodel('/data/eigil/work/lia_kq/Models/kg_budd_lia.mat');
    %     elseif strcmp(config.friction_law, 'budd_plastic')
    %         md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'budd_plastic.mat']);
    %         M = config.polynomial_order; % polynomial order
    %         % md = loadmodel('/data/eigil/work/lia_kq/Models/kg_budd_lia.mat');
    %     elseif strcmp(config.friction_law, 'weertman')
    %         md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'weertman.mat']);
    %         M = config.polynomial_order; % polynomial order
    %     else
    %         warning("Friction law not implemented")
    %     end
    %     extrapolated_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_slim_extend.exp', 2));
    %     % STATISTICS FOR BUDD LIA INIT
    %     % mean(mdb.results.StressbalanceSolution.Vel) = 715.5533
    %     % std(mdb.results.StressbalanceSolution.Vel) = 1.5335e+03
    %     % max(mdb.results.StressbalanceSolution.Vel) = 6.9819e+03
    %     % mean(log(1 + mdb.results.StressbalanceSolution.Vel)/log(10)) = 2.0830
    %     % std(log(1 + mdb.results.StressbalanceSolution.Vel)/log(10)) = 0.8722
    %     % max(log(1 + mdb.results.StressbalanceSolution.Vel)/log(10)) = 3.8440

    %     disp("Parameterizing to LIA initial state")
    %     md = parameterize(md, 'ParameterFiles/transient_lia.par');
    %     validate_flag = false; % TODO: move into config

    %     disp("Extrapolating friction coefficient...")
    %     if strcmp(config.friction_extrapolation, "bed_correlation")
    %         % save M for reference
    %         md.miscellaneous.dummy.bed_corr_polynomial_order = M;

    %         disp("Extrapolating friction coefficient correlated polynomially with bed topography")
    %         [extrapolated_friction, extrapolated_pos, ~] = friction_correlation_model(md, cs_min, M, config.friction_law, validate_flag);

    %     elseif strcmp(config.friction_extrapolation, 'exponential_correlation')
    %         [extrapolated_friction, extrapolated_pos, ~] = friction_exponential_model(md, cs_min, friction_law, validate_flag);
 
    %     elseif strcmp(config.friction_extrapolation, "constant")
    %         disp("Extrapolating friction coefficient using constant value")
    %         [extrapolated_friction, extrapolated_pos, ~] = friction_constant_model(md, cs_min, config.friction_law, validate_flag);

    %     elseif strcmp(config.friction_extrapolation, "pollard")
    %         disp("Extrapolating friction coefficient using pollard inversion")
    %         % md_pollard = loadmodel("/data/eigil/work/lia_kq/Models/PollardInversion.mat");
    %         % md_pollard = loadmodel("/data/eigil/work/lia_kq/pollard_budd1to5_avg2_lim966.mat");
    %         md_pollard = loadmodel("/data/eigil/work/lia_kq/pollard_newest.mat");
    %         fp = md_pollard.friction.coefficient;
    %         % f = load("/data/eigil/work/lia_kq/budd_fric_extrap_temp_scaled.mat");
    %         fp = f.fric;
    %         % f0 = md.friction.coefficient;
    %         % fp = rescale(fp, min(f0), max(f0));
    %         md.friction.coefficient(extrapolated_pos) = fp(extrapolated_pos);
    %     else
    %         warning("Invalid extrapolation method from config file. Choose random_field, linear or constant")
    %     end

    %     if ~strcmp(config.friction_extrapolation, "pollard")
    %         % set values under cs min to cs min
    %         extrapolated_friction(extrapolated_friction <= cs_min) = cs_min;
    %     end
    %     friction_field = md.friction.coefficient;
        % OFFSET CORRECT AND SAVE IN MD: 
        %TODO: MOVE THIS LOGIC INTO CREATE_CONFIG.M FUNCTION OR CREATE SEPERATE FUNCTION.
        % if strcmp(config.friction_extrapolation, 'pollard')
        %     disp('Pollard inversion, no offset correction')
        %     % offset = 4;
        %     % md.friction.coefficient(extrapolated_pos) = md.friction.coefficient(extrapolated_pos) * offset;
        %     friction_field = md.friction.coefficient;
        % else
        %     md_ss = loadmodel('/data/eigil/work/lia_kq/Models/KG_budd_ss.mat');

        %     % BUDD PLASTIC
        %     scaled_friction = md_ss.friction.coefficient .* (md_ss.results.StressbalanceSolution.Vel./md.constants.yts).^(2./5);
        %     md.friction.coefficient(extrapolated_pos) = scaled_friction(extrapolated_pos);
        %     friction_field = md.friction.coefficient;

        % end
        % elseif strcmp(config.friction_law, 'budd')
        %     if offset
        %         disp('Offset correction')
        %         if strcmp(config.friction_extrapolation, "bed_correlation")
        %             % offset = median(md.friction.coefficient) / 5;
        %             offset = 2; % budd origninal
        %             md.friction.coefficient(extrapolated_pos) = extrapolated_friction * offset;
        %         elseif strcmp(config.friction_extrapolation, "constant")
        %             offset = 250;
        %             md.friction.coefficient(extrapolated_pos) = offset;
        %         end
        %     else
        %         md.friction.coefficient(extrapolated_pos) = extrapolated_friction;
        %     end
        %     % md.friction.coefficient(pos_rocks) = cs_max;
        %     md.friction.coefficient(md.mask.ocean_levelset<0) = cs_min; 
        %     friction_field = md.friction.coefficient;

        % elseif strcmp(config.friction_law, 'weertman')
        %     if offset
        %         disp('Offset correction')
        %         if strcmp(config.friction_extrapolation, "bed_correlation")
        %             offset = 1.0;
        %             md.friction.C(extrapolated_pos) = extrapolated_friction * offset;
        %         elseif strcmp(config.friction_extrapolation, "constant")
        %             offset = 2350;
        %             md.friction.C(extrapolated_pos) = offset;
        %         end
        %     else
        %         md.friction.C(extrapolated_pos) = extrapolated_friction;
        %     end
        %     % md.friction.coefficient(pos_rocks) = cs_max;
        %     md.friction.C(md.mask.ocean_levelset<0) = cs_min; 
        %     friction_field = md.friction.C;

        % elseif strcmp(config.friction_law, 'schoof')
        %     if offset
        %         disp('Offset correction')
        %         if strcmp(config.friction_extrapolation, "bed_correlation")
        %             % offset = median(md.friction.C) / 10;
        %             offset = 1.5;
        %             md.friction.C(extrapolated_pos) = extrapolated_friction * offset;
        %         elseif strcmp(config.friction_extrapolation, "constant")
        %             offset = 2000;
        %             md.friction.C(extrapolated_pos) = offset;
        %         end
        %     else
        %         md.friction.C(extrapolated_pos) = extrapolated_friction;
        %     end
        %     % md.friction.C(pos_rocks) = cs_max;
        %     md.friction.C(md.mask.ocean_levelset<0) = cs_min; 
        %     friction_field = md.friction.C;
            
        % else
        %     warning('Friction law not recignised, choose schoof or budd')
        % end

    %     if plotting_flag
    %         plotmodel(md, 'data', friction_field, 'title', 'Friction Coefficient', ...
    %         'colorbar', 'off', 'xtick', [], 'ytick', [], 'xlim#all', xl, 'ylim#all', yl, 'figure', 61); 
    %         set(gca,'fontsize',12);
    %         set(colorbar,'visible','off')
    %         h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
    %         colormap('turbo'); 
    %         exportgraphics(gcf, "budd_friction_extrapolated.png")
    %     end

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

    %% 9 Initialise: Setup and load calving fronts
    if perform(org, 'fronts')
        if run_lia_parameterisation == 1
            disp("Using LIA initial conditoins")
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'lia.mat']);

        else
            disp("Not using LIA initial conditions")
            md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'friction.mat']);
        end
        
        if exist(['/data/eigil/work/lia_kq/Models/', prefix, 'fronts.mat'])
            md_front = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'fronts.mat']);
            md = fronts_init(md, output_frequency, start_time, final_time); % initialises fronts
            md.levelset.spclevelset = md_front.levelset.spclevelset;
        else
            md = fronts_init(md, output_frequency, start_time, final_time); % initialises fronts
            % md = fronts_transient(md, front_shp_file); % loads front observations
            md = stack2levelset(md, front_shp_file); % simpler version
        end
        savemodel(org, md);
    end

    %% 10 Transient: setup & run
    if perform(org, 'transient')
        md = loadmodel(['/data/eigil/work/lia_kq/Models/', prefix, 'fronts.mat']);

        % CHECK INITIAL STATE:
        md.inversion.iscontrol = 0;
        md = solve(md, 'sb');
        plotmodel(md, 'data', md.results.StressbalanceSolution.Vel, ...
                      'title', 'Initial state, Vel', 'caxis', [0 12e3], ...
                      'xtick', [], 'ytick', [], 'xlim', xl, 'ylim', yl, 'figure', 63); 
        set(gca,'fontsize',12);
        colormap('turbo'); 
        exportgraphics(gcf, "initial_state.png")

        plotmodel(md, 'data', md.friction.coefficient, ...
        'title', 'Friction coefficient', 'caxis', [0 100], ...
        'xtick', [], 'ytick', [], 'xlim', xl, 'ylim', yl, 'figure', 64); 
        set(gca,'fontsize',12);
        colormap('turbo'); 

        % meltingrate
        timestamps = [md.timestepping.start_time, md.timestepping.final_time];
        % md.frontalforcings.meltingrate=zeros(md.mesh.numberofvertices+1, numel(timestamps));
        md.frontalforcings.meltingrate = 0 .* ones(md.mesh.numberofvertices+1, numel(timestamps));

        md.frontalforcings.meltingrate(end, :) = timestamps;

        md.cluster = cluster;
        md.verbose.solution = 1;

        % fast solver
        md.toolkits.DefaultAnalysis=bcgslbjacobioptions();

        % for testing
        % md.timestepping.start_time = 1900;
        % md.timestepping.final_time = 1901;
        % md.levelset.spclevelset(end, 1) = 1880;
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