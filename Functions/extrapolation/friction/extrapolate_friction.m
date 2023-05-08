function [md, friction_field] = extrapolate_friction(md, config)
    M = config.polynomial_order;
    offset = logical(config.lia_friction_offset);
    cs_min = config.cs_min;
    cs_max = config.cs_max;
    % extrapolation_domain = '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_slim.exp';
    extrapolation_domain = '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_slim_extend.exp';
    % extrapolation_domain = '/data/eigil/work/lia_kq/Exp/extrapolation_domain/1900_extrapolation_area_large.exp';

    extrapolated_pos = find(ContourToNodes(md.mesh.x, md.mesh.y, extrapolation_domain, 2));

    disp("Extrapolating friction coefficient...")
    if strcmp(config.friction_extrapolation, "bed_correlation")
        % save M for reference
        md.miscellaneous.dummy.bed_corr_polynomial_order = M;

        disp("... using polynomial BED TOPOGRAPHY CORRELATION")
        [extrapolated_friction, ~, ~] = friction_correlation_model(md, cs_min, M, config.friction_law, true, extrapolation_domain);

    elseif strcmp(config.friction_extrapolation, "constant")
        disp("... using CONSTANT value")
        [extrapolated_friction, ~, ~] = friction_constant_model(md, cs_min, config.friction_law, extrapolation_domain);
    elseif strcmp(config.friction_extrapolation, "exponential")
        [extrapolated_friction, extrapolated_pos, ~] = friction_exponential_model(md, cs_min, config.friction_law, true, extrapolation_domain);
    elseif strcmp(config.friction_extrapolation, "pollard")
        disp("... using POLLARD inversion")
        % md_pollard = loadmodel('/data/eigil/work/lia_kq/pollard_budd.mat');
        % md_pollard = loadmodel('/data/eigil/work/lia_kq/steady_state_lia_budd.mat');
        fc = loadmodel('/data/eigil/work/lia_kq/schoof_pollard_fc.mat');
        % extrapolated_friction = md_pollard.friction.C(extrapolated_pos);
        extrapolated_friction = fc(extrapolated_pos);
    elseif strcmp(config.friction_extrapolation, "from_budd")
        disp("... using POLLARD inversion")
        md_pollard = loadmodel('/data/eigil/work/lia_kq/pollard_budd.mat');
        % extrapolated_friction = md_pollard.friction.C(extrapolated_pos);
        extrapolated_friction = fc(extrapolated_pos);
    end

    if offset
        disp('Offset correction')
        if strcmp(config.friction_extrapolation, "bed_correlation")
            extrapolated_friction = extrapolated_friction * config.lia_friction_offset;
        elseif strcmp(config.friction_extrapolation, "constant")
            extrapolated_friction = config.lia_friction_offset;
        end
    end
    
    extrapolated_friction(extrapolated_friction <= cs_min) = cs_min;
    extrapolated_friction(extrapolated_friction > cs_max) = cs_max;

    if strcmp(config.friction_law, 'budd')
        md.friction.coefficient(extrapolated_pos) = extrapolated_friction;
        friction_field =  md.friction.coefficient;
    else
        md.friction.C(extrapolated_pos) = extrapolated_friction;
        friction_field =  md.friction.C;
    end



end