function [ssimval, ssimmap, wasserstein_dist] = visual_similarity(A, B)
    %% Compute SSIM, 1 is better
    [ssimval, ssimmap] = ssim(A, B);

    %% Compute Wasserstein (Earth mover's) distance, 0 is better
    % Histograms
    nbins = 100;
    [ca, ha] = imhist(A, nbins);
    [cb, hb] = imhist(B, nbins);

    % Features
    f1 = ha;
    f2 = hb;

    % Weights
    w1 = ca / sum(ca);
    w2 = cb / sum(cb);

    % Earth Mover's Distance
    [~, wasserstein_dist] = emd(f1, f2, w1, w2, @gdf);
end
