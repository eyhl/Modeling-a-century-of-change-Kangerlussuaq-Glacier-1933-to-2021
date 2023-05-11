function [] = movie_vel_transient_error(md, movieName)
    % get it to fail if I forget name.
    movieName = movieName;
    set(0,'defaultfigurecolor',[1, 1, 1])
    t_model = [md.results.TransientSolution.time];
    vel_model = [md.results.TransientSolution.Vel];
    measure_obs = load('/data/eigil/work/lia_kq/Data/validation/velocity/velObs_onmesh.mat');
    indeces_start = find_closest_times(t_model, measure_obs.TStart);
    transient_errors = get_transient_vel_errors(vel_model, measure_obs.vel_onmesh, t_model, measure_obs.TStart, measure_obs.TEnd);

    N =  length(measure_obs.TStart);
    
    xl = [4.658, 5.102] * 1e5;
    yl = [-2.3039, -2.2663] * 1e6;

    clear mov;
    close all;
    figure()
    mov(1:N) = struct('cdata', [],'colormap', []);

    count = 1;
    for i = 1:N
        if isfield(md.results.TransientSolution, 'MaskIceLevelset')
            masked_values = md.results.TransientSolution(indeces_start(i)).MaskIceLevelset;
        else
            masked_values = md.mask.ice_levelset;
        end

        plotmodel(md,'data', transient_errors(:, i),...
            'levelset', masked_values, 'gridded', 1,...
            'caxis', [-1000, 1000], 'colorbar', 'on',...
            'xtick', [], 'ytick', [], ...
            'xlim', xl, 'ylim', yl);%, ...
            % 'tightsubplot#all', 1,...
            % 'hmargin#all', [0.01,0.0], 'vmargin#all',[0,0.06], 'gap#all',[.0 .0]); %,...
            % 'subplot', [nRows,nCols,subind(j)]);
        title(sprintf('Velocity misfit\nmodel time: %s, data time: %s', datestr(decyear2date(t_model(indeces_start(i))), 'yyyy-mm-dd'), datestr(decyear2date(measure_obs.TStart(i)), 'yyyy-mm-dd')))
        set(gca,'fontsize', 10);
        % set(colorbar,'visible','off')
        % h = colorbar('Position', [0.1  0.1  0.75  0.01], 'Location', 'southoutside');
        % title(h, datestr( decyear2date(time(i)), 'yyyy-mm-dd'))
        colormap('turbo')
        img = getframe(1);
        img = img.cdata;
        mov(count) = im2frame(img);
        % set(h, 'visible','off');
        % clear h;
        fprintf(['step ', num2str(count),' done\n']);
        count = count+1;
        clf;
    end
    % create video writer object
    writerObj = VideoWriter(movieName);
    % set the frame rate to one frame per second
    set(writerObj,'FrameRate', 2);
    % open the writer
    open(writerObj);

    for i=1:N
        img = frame2im(mov(i));
        [imind,cm] = rgb2ind(img,256,'dither');
        % convert the image to a frame using im2frame
        frame = im2frame(img);
        % write the frame to the video
        writeVideo(writerObj,frame);
    end
    close(writerObj);