function [] = friction_extrapolation_comparison(md)
    cs_min = 0.01;
    friction_law = 'schoof';
    validate_flag = true;
    M = 1;

    [extrapolated_friction, extrapolated_pos, mae_const] = friction_constant_model(md, cs_min, friction_law, validate_flag);
    [extrapolated_friction, extrapolated_pos, mae_poly] = friction_polynomial_model(md, cs_min, M, friction_law, validate_flag); 
    [extrapolated_friction, extrapolated_pos, mae_rf] = friction_random_field_model(md, cs_min, friction_law, validate_flag); 
    fprintf('Constant extrapolation MAE = %.2f', mae_const);
    fprintf('Polynomial extrapolation MAE = %.2f', mae_poly);
    fprintf('Random field extrapolation MAE = %.2f', mae_rf);
end 