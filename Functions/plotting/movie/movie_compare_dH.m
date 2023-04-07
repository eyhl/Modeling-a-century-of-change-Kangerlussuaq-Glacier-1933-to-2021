function [] = movie_compare_dH(md1, md2, movieName)
    xl = [4.578, 5.152]*1e5;
    yl = [-2.3039, -2.2563]*1e6;

    start_time = 1900;
    final_time = 2020;
    thickness1 = [md1.results.TransientSolution(:).Thickness];
    thickness2 = [md2.results.TransientSolution(:).Thickness];
    [yearly_avg1, first_index1] = yearly_average(md1, thickness1, start_time, final_time); % only one data point for 2021
    [yearly_avg2, first_index2] = yearly_average(md2, thickness2, start_time, final_time); % only one data point for 2021

    % TODO: ADD d(thicknesss)/dt plot
    set(0,'defaultfigurecolor',[1, 1, 1])
    % n_times = size(md.results.TransientSolution(:).Vel, 2)
    time = start_time:final_time;
    Nt =  length(time);
    nstep = 1;
    nframes = length(time);
    ice_masks = [md1.results.TransientSolution(:).MaskIceLevelset];
    size(ice_masks)
    clear mov;
    close all;
    figure()
    mov(1:nframes) = struct('cdata', [],'colormap', []);
    count = 1;
    dH_acc = 0;

    for i = 1:nstep:Nt
        dH = yearly_avg1(1:end-1, i) - yearly_avg2(1:end-1, i);
        dH_acc = dH_acc + dH;
        plotmodel(md1, 'data', dH, 'data', dH, ...
            'levelset#all', ice_masks(:, first_index1(i)), 'gridded#all', 1,...
            'caxis#all', [-5000, 5000], 'colorbar#all', 'off',...
            'xtick#all', [], 'ytick#all', [], ...
            'tightsubplot#all', 1, ...
            'xlim#1', xl, 'ylim#1', yl, ...
            'hmargin#all', [0.01,0.0], 'vmargin#all',[0,0.06], 'gap#all',[.0 .0]); %,...
            % 'subplot', [nRows,nCols,subind(j)]);
        title('Difference between models', 'interpreter','latex')
        set(gca,'fontsize',12);
        set(colorbar,'visible','off')
        h = colorbar('Position', [0.1  0.05  0.75  0.01], 'Location', 'southoutside');
        title(h, int2str(time(i)))
        colormap('turbo')
        img = getframe(1);
        img = img.cdata;
        mov(count) = im2frame(img);
        set(h, 'visible','off');
        clear h;
        fprintf(['step ', num2str(count),' done\n']);
        count = count+1;
        clf;
    end
    % create video writer object
    writerObj = VideoWriter(movieName);
    % set the frame rate to one frame per second
    set(writerObj,'FrameRate', 20);
    % open the writer
    open(writerObj);


    for i=1:nframes
        img = frame2im(mov(i));
        [imind,cm] = rgb2ind(img,256,'dither');
        % convert the image to a frame using im2frame
        frame = im2frame(img);
        % write the frame to the video
        writeVideo(writerObj,frame);
    end
    close(writerObj);