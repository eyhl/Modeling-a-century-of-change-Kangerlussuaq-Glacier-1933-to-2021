function [] = movie_dHdt(md, movieName)
    % TODO: ADD d(thicknesss)/dt plot
    set(0,'defaultfigurecolor',[1, 1, 1])
    % n_times = size(md.results.TransientSolution(:).Vel, 2)
    time = [md.results.TransientSolution.time];
    % output_freq = md.settings.output_frequency;
    % time = time(1:output_freq:end);
    length(time)
    Nt =  length(time);
    nstep = 1;
    nframes = floor(Nt/nstep) - 1;
    xl = [4.578, 5.152]*1e5;
    yl = [-2.3039, -2.2563]*1e6;

    clear mov;
    close all;
    figure()
    mov(1:nframes) = struct('cdata', [],'colormap', []);
    count = 1;
    for i = 2:nstep:Nt
        dH = md.results.TransientSolution(i).Thickness - md.results.TransientSolution(i-1).Thickness;
        plotmodel(md,'data', dH/(time(i) - time(i-1)),...
            'levelset', md.results.TransientSolution(i).MaskIceLevelset, 'gridded', 1,...
            'caxis', [-50, 50], 'colorbar', 'off',...
            'xtick', [], 'ytick', []);%, ...
            % 'tightsubplot#all', 1,...
            % 'hmargin#all', [0.01,0.0], 'vmargin#all',[0,0.06], 'gap#all',[.0 .0]); %,...
            % 'subplot', [nRows,nCols,subind(j)]);
        title('dHdt', 'interpreter','latex')
        set(gca,'fontsize',12);
        set(colorbar,'visible','off')
        h = colorbar('Position', [0.1  0.05  0.75  0.01], 'Location', 'southoutside');
        title(h, datestr( decyear2date(time(i)), 'yyyy-mm-dd'))
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