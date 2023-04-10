function T = quantify_field_difference(md, field_A, field_B, save_as, log_comparison, plotting, axs)
    N = 2; % if log is not used
    if log_comparison
        N = 3;
    end
    % Fast flowing / lower part of domain definition
    if nargin < 7
        axs = 1.0e+06 * [0.4533, 0.5123, -2.3140, -2.2425]; % xmin, xmax, ymin, ymax
        if nargin<6
            plotting = false;
        end
    end
    
    RMSE = NaN(1, N);
    MEDIAN = NaN(1, N);
    SD = NaN(1, N);
    SSIM = NaN(1, N);
    WS_DIST = NaN(1, N);

    % for plotting
    ssimmap_list = {};
    error_list = {};
    ID = {};

    %% quantify visual similarity
    %  ------------------------------------- Full domain -------------------------------------
    i = 1;
    ID{i} = 'Full Domain';
    % define grids, 1:10 ratio is from domain aspect to get approx. square image
    min_x = min(md.mesh.x); 
    max_x = max(md.mesh.x);
    min_y = min(md.mesh.y);
    max_y = max(md.mesh.y);
    x_grid = linspace(min_x, max_x, 1000);   
    y_grid = linspace(min_y, max_y, 10000);   
    area1 = abs(max_x - min_x) * abs(max_y - min_y);

    %% Compute RMSE between fields
    masked_values = md.mask.ice_levelset<0;
    errors1 = field_A - field_B;
    se = (errors1).^2;   
    [intData, meanData, areas] = integrateOverDomain(md, se, ~masked_values);
    rmse = sqrt(meanData);
    RMSE(i) = rmse;

    %% Compute residual histogram and statistics
    MEDIAN(i) = median(errors1); 
    SD(i) = std(errors1); 
    error_list{i} = errors1;

    %% Interpolate fields onto a square grid
    A = InterpFromMeshToGrid(md.mesh.elements, md.mesh.x, md.mesh.y, field_A, x_grid, y_grid, 0);
    B = InterpFromMeshToGrid(md.mesh.elements, md.mesh.x, md.mesh.y, field_B, x_grid, y_grid, 0);
    [ssimval1, ssimmap1, wasserstein_dist1] = visual_similarity(A, B);
    ssimmap_list{i} = ssimmap1;
    SSIM(i) = ssimval1;
    WS_DIST(i) = wasserstein_dist1;

    %% ------------------------------------- Log evaluation -------------------------------------
    if log_comparison
        N = 3; %

        i = i + 1;
        ID{i} = 'Log Domain';
        masked_values = md.mask.ice_levelset<0;
        squared_log_error = log_misfit(field_A, field_B, ~masked_values);
        [intData, meanData, areas] = integrateOverDomain(md, squared_log_error, ~masked_values);
        log_rmse = sqrt(meanData);    
        RMSE(i) = log_rmse;

        %% Compute residual histogram and statistics
        MEDIAN(i) = median(sqrt(squared_log_error)); 
        SD(i) = std(sqrt(squared_log_error)); 
        error_list{i} = sqrt(squared_log_error);

        %% Interpolate fields onto a square grid
        A = InterpFromMeshToGrid(md.mesh.elements, md.mesh.x, md.mesh.y, log10(field_A + 1e-10), x_grid, y_grid, 0);
        B = InterpFromMeshToGrid(md.mesh.elements, md.mesh.x, md.mesh.y, log10(field_B + 1e-10), x_grid, y_grid, 0);
        [ssimval12, ssimmap12, wasserstein_dist12] = visual_similarity(A, B);
        ssimmap_list{i} = ssimmap12;
        SSIM(i) = ssimval12;
        WS_DIST(i) = wasserstein_dist12;
    end

    %  ------------------------------------- Fast flowing / lower part of domain -------------------------------------
    i = i + 1;
    ID{i} = 'Fast Domain';

    % define grids, 1:10 ratio is from domain aspect to get approx. square image
    min_x = min(axs(1)); 
    max_x = max(axs(2));
    min_y = min(axs(3));
    max_y = max(axs(4));
    x_grid = linspace(min_x, max_x, 500);   
    y_grid = linspace(min_y, max_y, 5000);   
    area2 = abs(max_x - min_x) * abs(max_y - min_y);

    %% Compute RMSE between fields
    masked_x = md.mesh.x < max_x & md.mesh.x > min_x;
    masked_y = md.mesh.y < max_y & md.mesh.y > min_y;
    masked_values = masked_x & masked_y;
    errors2 = field_A - field_B;
    se = (errors2).^2;   
    [intData, meanData, areas] = integrateOverDomain(md, se, ~masked_values); % sets mask values to NaN
    rmse = sqrt(meanData);
    RMSE(i) = rmse;

    %% Compute residual histogram and statistics
    MEDIAN(i) = median(errors2); 
    SD(i) = std(errors2); 
    error_list{i} = errors2;

    %% Interpolate fields onto a square grid
    A = InterpFromMeshToGrid(md.mesh.elements, md.mesh.x, md.mesh.y, field_A, x_grid, y_grid, 0);
    B = InterpFromMeshToGrid(md.mesh.elements, md.mesh.x, md.mesh.y, field_B, x_grid, y_grid, 0);
    [ssimval2, ssimmap2, wasserstein_dist2] = visual_similarity(A, B);
    ssimmap_list{i} = ssimmap2;
    SSIM(i) = ssimval2;
    WS_DIST(i) = wasserstein_dist2;

    ID = transpose(ID);
    RMSE = transpose(RMSE);
    MEDIAN = transpose(MEDIAN);
    SD = transpose(SD);
    SSIM = transpose(SSIM);
    WS_DIST = transpose(WS_DIST);

    T = table(string(ID), RMSE, MEDIAN, SD, SSIM, WS_DIST);
    T = renamevars(T, ["Var1"], ["ID"]);

    disp("Statistics");
    disp(T);
    % writetable(T, filename);
    writetable(T, append(save_as, '_visual_quantification.dat'), 'WriteRowNames', true)

    if plotting
        figure(1234)
        for i = 1:N
            subplot(1, N, i);
            imshow(flipud(ssimmap_list{i}))
            daspect([1000 10000 1])
            colorbar();
            title(["SSIM ", ID(i)])
        end
        set(gcf,'Position',[100 100 1500 500])
        exportgraphics(gcf, append(save_as, '_SSIM_maps.png'), 'Resolution', 300)

        figure(1233)
        subplot(1,2,1)
        histogram(error_list{1}, 100);
        hold on
        histogram(error_list{end});
        legend(ID{1}, ID{end})
        subplot(1,2,2)
        histogram(error_list{1}, 200);
        hold on
        histogram(error_list{end});
        legend(ID{1}, ID{end})
        xlim([-1000, 1000])
        set(gcf,'Position',[100 100 1500 500])
        exportgraphics(gcf, append(save_as, '_Residual_histograms.png'), 'Resolution', 300)
        hold off
        clf;
    end
end