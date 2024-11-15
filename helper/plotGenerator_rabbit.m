%% plotGenerator
% Example usage: plt = plotGenerator_rabbit

%% Class for data analysis
% contains:
% grpAvg_combined
% bar_swarm_combined
% heatmap_but_image
% schematics_rabbit
% sig_p = doANOVA
% out_string = string_split_helper(obj, in_string1, in_string2)
% [sigPos, P] = getRankSumP(obj, df_bs, df_ctrl, fStr, eStr)

classdef plotGenerator_rabbit    
    properties
        baseDir
        homeDir
        dataDir
        plotDir        
        allData
        allData_indiv
        allData_group
        sidList
        N
        fontSize = 22;
        lineWeight = 1.5;
        titleFontSize = 30;
        fileFormat = 'png';
        eye = {'L' 'R'};
        eyeLabel = {'Left Eye' 'Right Eye'};
        cond = {'bs' 'ctrl'};
        condLabel = {'Blind Spot' 'Control Spot'};
        nf = {'F2' 'F3'};
        flashLabel = {'2 Real Flashes' '3 Real Flashes'};
        nb = [0 2 3];
        nresp = 0:4;
        colors = repelem([0:.25:1].',1,3); 
        allColors = {'red' 'purple' 'green' 'blue' 'yellow' 'lightblue' 'brick' 'brown' };
        pixSize = 600/3840;
        viewDist = 570*2;
        half = (tand(.5)/2*(570*2))/(600/3840);
        SIDs_extraFlash = {'SV009' 'SV012' 'SV026' 'SV027' 'SV028' ...
                           'SV029' 'SV030' 'SV031' 'SV032' 'SV033'};
        b3_col = [1 .75 0]; % amber
        b2_col = [.5 0 .5]; % purple
        b0_col = [1 0 0]; % red
    end

    methods
        function obj = plotGenerator_rabbit
            userID = extractBetween(pwd,['Users',filesep], filesep);
            obj.baseDir = extractBefore(pwd, 'blindspot-multisensory');
            obj.homeDir = char(fullfile(obj.baseDir, 'blindspot-multisensory'));
            obj.dataDir = char(fullfile(obj.homeDir, 'Data'));
            obj.plotDir = char(fullfile(obj.homeDir, 'plots'));
            obj.allData = genAllData_rabbit;
            obj.allData_indiv = obj.allData(cellfun(@(x) contains(x, 'SV'), {obj.allData.SID}));
            obj.allData_group = obj.allData(cellfun(@(x) contains(x, 'group'), {obj.allData.SID}));
            obj.sidList = unique({obj.allData_indiv.SID});
            obj.N = numel(obj.sidList);
        end % end of plotGenerator

        %% grouped bar charts with swarm
        function grpAvg_combined(obj)
            stim = {'flash' 'beep'};
            stat = {'avg'}; %'acc' 

            for s=stim
                for a=stat
                    obj.bar_swarm_combined(a{1}, true, s{1}, true);
                end
            end
        end % end of function grpAccAvg_combined

        function bar_swarm_combined(obj, varargin)
            close all
            while ~isempty(varargin)
                switch lower(varargin{1})
                    case 'acc'
                        ylabelText = 'Accuracy';
                        sgtitleText = 'Accuracy on reporting true # of %s (N = %d)';
                        figPre = 'accuracy';
                        ylim([0 1])
                        a = 'acc';
                    case 'avg'
                        ylabelText = '# %s perceived';
                        sgtitleText = 'Average number of %s perceived (N = %d)';
                        figPre = 'average';
                        ylim([0 3])
                        a = 'avg';
                    case 'flash'
                        suffix = '';
                        figName = [figPre '_flash_combined.', obj.fileFormat];
                        var = 'flash(es)';
                    case 'beep'
                        suffix = '_b';
                        figName = [figPre '_beep_combined.', obj.fileFormat];
                        var = 'beep(s)';
                end
                varargin(1:2) = [];
            end

            fig = figure;
            % fig = figure('Visible','off');
            set(gcf,'position',[100 100 1000 700]);
            tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
            % xlabelText = {'B0'; 'B2'; 'B3'}; 
            xlabelText = {'0'; '2'; '3'};

            for f=1:numel(obj.nf) % F2, F3
                s = obj.filterRows(obj.allData_group, 'eye', 'both');
                nexttile
                data4bar = zeros([3,2]);
                data4swarm = []; % N x 6 double
                for d=1:numel(xlabelText) % B0, B2, B3
                    for c=1:numel(obj.cond) % bs, ctrl
                        data4bar(d,c) = mean(s.(a)(d+1).([obj.cond{c} obj.nf{f} suffix]));
                        sterr(d,c) = std(s.(a)(d+1).([obj.cond{c} obj.nf{f} suffix])); %/sqrt(obj.N);
                        data4swarm = [data4swarm, s.(a)(d+1).([obj.cond{c} obj.nf{f} suffix]).'];
                    end
                end
                % do ranksum and get p values
                df_bs = {s.(a)(2:end).(['bs' obj.nf{f} suffix])};
                df_ctrl = {s.(a)(2:end).(['ctrl' obj.nf{f} suffix])};
                [sigPos, P] = getRankSumP(obj, df_bs, df_ctrl, obj.nf{f}, 'Both eyes');

                % bar
                hb = bar(data4bar, 'grouped', 'FaceColor','flat');
                xticklabels(xlabelText);
                % change color for F2B3 and F3B2
                if f == 1
                    hb(1).CData = [0 0 0; 0 0 0; hex2rgb('#6636A5')];
                    hb(2).CData = [.7 .7 .7; .7 .7 .7; hex2rgb('#EBDAFF')];
                else
                    hb(1).CData = [0 0 0; hex2rgb('#6636A5'); 0 0 0];
                    hb(2).CData = [.7 .7 .7; hex2rgb('#EBDAFF'); .7 .7 .7];
                end
                hold on             
                

                % signifance and labels
                % sigPos={}; P=[]; 
                sig_p = obj.doANOVA;
                offset = .1;
                sigPos={};
                % F2, average, flash
                if f == 1 && strcmp(a, 'avg') && isempty(suffix)
                    p_cell = sig_p.flash.avg_F2;
                    % build sigPos cell and P double array
                    P = cell2mat(p_cell(:,2)).'; 
                    for row=1:length(p_cell)
                        sigPos{end+1} = obj.create_sigPos(p_cell{row,1}, offset);
                    end
                    text(2.6,.4,'Illusory AV Rabbit','FontSize',18,'FontWeight','bold','Color',hex2rgb('#6636A5'),'Rotation',90)

                elseif f == 2 && strcmp(a, 'avg') && isempty(suffix)
                    p_cell = sig_p.flash.avg_F3;
                    % build sigPos cell and P double array
                    P = cell2mat(p_cell(:,2)).'; 
                    for row=1:length(p_cell)
                        sigPos{end+1} = obj.create_sigPos(p_cell{row,1}, offset);
                    end
                    text(1.6,.4,'Invisible AV Rabbit','FontSize',18,'FontWeight','bold','Color',hex2rgb('#6636A5'),'Rotation',90)
                else % beeps
                    % 0 vs 3 ***
                    % 0 vs 2 ***
                    % 2 vs 3 ***
                    sigPos = {[1 3]; [1 2]; [2 3]};
                    P = [1e-05, 1e-05, 1e-05];
                end
                sigstar(sigPos, P);

                % error bars
                % see https://www.mathworks.com/matlabcentral/answers/102220-how-do-i-place-errorbars-on-my-grouped-bar-graph-using-function-errorbar-in-matlab
                % Calculate the number of groups and number of bars in each group
                [ngroups,nbars] = size(data4bar);
                % Get the x coordinate of the bars
                x = nan(nbars, ngroups);
                for i = 1:nbars
                    x(i,:) = hb(i).XEndPoints;
                end
                % Plot the errorbars
                % errorbar(x',data4bar,zeros(size(sterr)), sterr,'k','LineWidth', obj.lineWeight, 'CapSize',0, 'LineStyle','none');

                % swarm
                padding = .15;
                x = [ones(obj.N,1)-padding, ones(obj.N,1)+padding, ...
                    2*ones(obj.N,1)-padding, 2*ones(obj.N,1)+padding, ...
                    3*ones(obj.N,1)-padding, 3*ones(obj.N,1)+padding];
                swarmchart(x,data4swarm,'filled','MarkerFaceColor', [1 1 1], 'MarkerFaceAlpha',0.9,'XJitterWidth',.2, 'MarkerEdgeColor',[0 0 0]);
                ylim([0 4.6])
                title(obj.flashLabel{f})
                if f == 1 %F2
                    ylabel(sprintf(ylabelText, var))                
                end                
                xlabel('Number of beeps')                
                set(gca,"FontSize", obj.fontSize)

                % lines to indicate 1, 2, or 3
                if a == 'acc'
                    yline(1, 'k--', 'LineWidth', obj.lineWeight);
                else % a == 'avg'
                    if f == 1 %F2
                        yline(2, 'k--', 'LineWidth', obj.lineWeight);
                    else %F3
                        yline(3, 'k--', 'LineWidth', obj.lineWeight);
                    end

                    % add lines on 2 and 3 if it's a beep plot
                    if ~isempty(suffix) % '_b'
                        yline([2 3], 'k--', 'LineWidth', obj.lineWeight); 
                    end

                end
            end
            lg = legend({'Blind spot' 'Control spot' ''}, 'Location','southwest');
            lg.Position = [0.88,0.5,0.06,0.09];
            lg.Layout.Tile = 'east';
            sgtitle(sprintf(sgtitleText, var, obj.N), "FontSize", obj.fontSize, 'FontWeight', 'bold');
            saveas(fig, fullfile(obj.plotDir, figName))
            close

        end % end of function bar_swarm_combined
        
        %% heatmap       
        function heatmap_but_image(obj)
            % take out B2 conditions
            % see https://www.mathworks.com/matlabcentral/answers/838348-how-to-change-heatmap-data-labels
            nf = {'F2' 'F3'};
            x_coords = {[.15 .19], [.56 .6]};
            for f=1:numel(nf) % F2, F3
                close all
                fig = figure;
                % fig = figure('Visible','off');
                % set(gcf,'position',[100 100 800 700]);
                set(gcf,'position',[100 100 800 1000]);
                tiledlayout(1,2, 'TileSpacing', 'compact');
                for c=1:numel(obj.cond) % bs, ctrl
                    ax = nexttile;
                    s = obj.filterRows(obj.allData_group, 'eye', 'both');
                    beepConds = {'B0' 'B2' 'B3'};  
                    arr = [];
                    for b=1:numel(beepConds)                        
                        arr = [arr; s.probLoc.([obj.cond{c} nf{f} beepConds{b}])];
                    end
                    % flip arr upside down
                    arr = flip(arr);
                    
                    % arr = zeros(5,5);
                    h = imagesc(arr);
                    % set(ax,'XTick',1:5,'YTick',1:15,'YTickLabel',repmat(4:-1:0,1,3))
                    set(ax,'XTick',1:5,'YTick',1:15,'YTickLabel',4:-1:0)
                    ax.TickLength(1) = 0;
                    hold on

                    xlabel('Flash locations')
                    title(obj.condLabel{c})                 

                    % Create heatmap's colormap
                    n=256;
                    % cmap = [linspace(.9,0,n)', linspace(.9447,.447,n)', linspace(.9741,.741,n)'];
                    % colormap(cmap);
                    colormap sky
                    clim([0 1]);
                    
                    if c == 1 % bs
                        ylabel('# flash(es) perceived')
                    else % ctrl
                        colorbar
                    end
                    
                    % add dashed lines to separate B0, B2, B3
                    row = [5, 10];
                    yline(ax, row+.5, 'k--', 'LineWidth', obj.lineWeight);

                    % add text to indicate B3, B2, B0
                    text(1, 1, 'B3', 'VerticalAlignment', 'middle','HorizontalAlignment','Center', 'FontSize', obj.fontSize, 'FontWeight', 'bold');
                    text(1, 6, 'B2', 'VerticalAlignment', 'middle','HorizontalAlignment','Center', 'FontSize', obj.fontSize, 'FontWeight', 'bold');
                    text(1, 11, 'B0', 'VerticalAlignment', 'middle','HorizontalAlignment','Center', 'FontSize', obj.fontSize, 'FontWeight', 'bold');

                    % add arrows to annotate important conditions
                    % b3_col = hex2rgb('BF5700'); %[0.8500 0.3250 0.0980];
                    % b2_col = hex2rgb('702963'); %[0.2 0.53 0];
                    annotation('textarrow', x_coords{c}, [.82 .82], 'Color', obj.b3_col, 'LineWidth', 2) % B3, resp 3
                    annotation('textarrow', x_coords{c}, [.77 .77], 'Color', obj.b3_col, 'LineWidth', 2) % B3, resp 2
                    annotation('textarrow', x_coords{c}, [.51 .51], 'Color', obj.b2_col, 'LineWidth', 2) % B2, resp 2
                    if f == 1
                        annotation('textarrow', x_coords{c}, [.24 .24], 'Color', obj.b0_col, 'LineWidth', 2) % B0, resp 2
                    else
                        if c == 1 % blind spot
                            annotation('textarrow', x_coords{c}, [.24 .24], 'Color', obj.b0_col, 'LineWidth', 2) % B0, resp 2
                        else
                            annotation('textarrow', x_coords{c}, [.3 .3], 'Color', obj.b0_col, 'LineWidth', 2) % B0, resp 3
                        end
                    end
                    
                    % add symbols in cell to indicate physical flashes
                    if f == 1
                        columns = [2,4];
                    else
                        columns = [2,3,4];
                    end
                    for col=columns
                        for row=1:length(arr)
                            text(col, row, '◊', 'VerticalAlignment', 'middle','HorizontalAlignment','Center', 'FontSize', 12);
                        end
                    end
                    set(gca,'FontSize', obj.fontSize)
                end
            sgtitle(obj.flashLabel{f}, 'FontSize', obj.fontSize, 'FontWeight', 'bold')
            figName = ['heatmap_combined_' nf{f} '.' obj.fileFormat];
            % figName = ['heatmap_' nf{1} beepConds{b} '.png'];
            saveas(fig, fullfile(obj.plotDir, figName))
            close            
            end

        end % end of function heatmap_combined

        %% Schematics       
        function schematics_rabbit(obj)
            close all
            fig = figure; 
            tiledlayout(2,3, 'TileSpacing', 'compact');
            set(gcf,'position',[100 100 1500 800]);

            fb = [ 2 0; 2 2; 2 3; ...
                   3 0; 3 3; 3 2];

            titles = {'F2B0', 'F2B2', 'F2B3 (Illusory AV Rabbit)', ...
                      'F3B0', 'F3B3', 'F3B2 (Invisible AV Rabbit)'};

            aud_Y = 0.3; vis_Y = aud_Y + .9;

            lineWeight = 2; height = .5;
            numFontSize = 13;
            padding = .25;
            msPadding = .1;
            x = 3.5:12.5;
            xStart = [x(1)+1 x(1)+4 x(1)+7];

            for n=1:length(fb)
                nexttile
                axis off square 
                % Visual
                plot(x, ones(length(x))*vis_Y, 'k-', 'LineWidth', lineWeight); hold on
                text(x(1)-3, vis_Y+padding, 'Visual', 'FontSize', 16);
                % text(x(1), vis_Y-msPadding, '23ms', 'FontSize', numFontSize);
                if fb(n,1) == 2
                    obj.makeSchematicsBlock(xStart(1), xStart(1)+1, vis_Y, vis_Y+height, 'k-', lineWeight, '17ms', numFontSize, msPadding)
                    obj.makeSchematicsBlock(xStart(3), xStart(3)+1, vis_Y, vis_Y+height, 'k-', lineWeight, '17ms', numFontSize, msPadding)
                    text(xStart(2)-.8, vis_Y-msPadding, '113ms', 'FontSize', numFontSize);
                else % f == 3
                    obj.makeSchematicsBlock(xStart(1), xStart(1)+1, vis_Y, vis_Y+height, 'k-', lineWeight, '17ms', numFontSize, msPadding)
                    obj.makeSchematicsBlock(xStart(2), xStart(2)+1, vis_Y, vis_Y+height, 'k-', lineWeight, '17ms', numFontSize, msPadding)
                    obj.makeSchematicsBlock(xStart(3), xStart(3)+1, vis_Y, vis_Y+height, 'k-', lineWeight, '17ms', numFontSize, msPadding)
                    text(xStart(1)+1.2, vis_Y-msPadding, '48ms', 'FontSize', numFontSize);
                    text(xStart(2)+1.2, vis_Y-msPadding, '48ms', 'FontSize', numFontSize);
                end

                % Auditory
                plot(x, ones(length(x))*aud_Y, 'k-', 'LineWidth',lineWeight); hold on
                text(x(1)-3, aud_Y+padding,'Auditory', 'FontSize',16);

                if fb(n,2) == 2
                    obj.makeSchematicsBlock(xStart(1), xStart(1)+.5, aud_Y, aud_Y+height, 'k-', lineWeight, '7ms', numFontSize, msPadding)
                    obj.makeSchematicsBlock(xStart(3), xStart(3)+.5, aud_Y, aud_Y+height, 'k-', lineWeight, '7ms', numFontSize, msPadding)
                    text(xStart(2)-.8, aud_Y-msPadding, '123ms', 'FontSize', numFontSize);
                elseif fb(n,2) == 3
                    obj.makeSchematicsBlock(xStart(1), xStart(1)+.5, aud_Y, aud_Y+height, 'k-', lineWeight, '7ms', numFontSize, msPadding)
                    obj.makeSchematicsBlock(xStart(2), xStart(2)+.5, aud_Y, aud_Y+height, 'k-', lineWeight, '7ms', numFontSize, msPadding)
                    obj.makeSchematicsBlock(xStart(3), xStart(3)+.5, aud_Y, aud_Y+height, 'k-', lineWeight, '7ms', numFontSize, msPadding)
                    text(xStart(1)+1, aud_Y-msPadding, '58ms', 'FontSize', numFontSize);
                    text(xStart(2)+1, aud_Y-msPadding, '58ms', 'FontSize', numFontSize);
                end
                xlim([0 15]); ylim([0 vis_Y+.8]);
                xticks([])
                yticks([])
                text(x(9), aud_Y-.2, 'Time \rightarrow ', 'FontSize', numFontSize, 'FontAngle', 'italic');
                title(titles{n}, 'FontSize', 16)
                set(gca, 'TickLength', [0 0])
            end


            figName = 'schematics_allConditions.png';
            exportgraphics(fig, fullfile(obj.homeDir, 'plots', figName))
            close

        end % end of function schematics_rabbit

        %% Stats
        function sig_p = doANOVA(obj)

            s = obj.filterRows(obj.allData_group, 'eye', 'both');

            % struct to store fields with p<.05
            sig_p = struct;

            for stim={'flash' 'beep'}                
                if strcmp(stim{1}, 'beep')
                    suffix = '_b';
                else
                    suffix = '';
                end
                for a={'avg'} % skip accuracy for now
                    for f={'F2' 'F3'}

                        sig_p.(stim{1}).([a{1} '_' f{1}]) = {};

                        y = [s.(a{1})(2).(['bs' f{1} suffix]), ...
                             s.(a{1})(3).(['bs' f{1} suffix]), ...
                             s.(a{1})(4).(['bs' f{1} suffix]), ...
                             s.(a{1})(2).(['ctrl' f{1} suffix]), ...
                             s.(a{1})(3).(['ctrl' f{1} suffix]), ...
                             s.(a{1})(4).(['ctrl' f{1} suffix])];

                        % bs, ctrl
                        g1 = [zeros(1, obj.N*3), ones(1, obj.N*3)];

                        % B0, B2, B3
                        g2 = [zeros(1, obj.N), ones(1, obj.N)*2, ones(1, obj.N)*3, ...
                              zeros(1, obj.N), ones(1, obj.N)*2, ones(1, obj.N)*3];

                        [p,tt,stats, terms] = anovan(y,{g1 g2},"Model","full", ...
                            "varnames", ["BS/CTRL","B0/B2/B3"], "display", "off");
                        fprintf(['\n\n' a{1} '  ' f{1} '  ' stim{1} ' trials: \n'])
                        % convert tbl (cell array) to table
                        T = cell2table(tt(2:end,:),'VariableNames',tt(1,:));

                        % % add to sig_p struct
                        % to_keep = find(p<.05).';
                        % for row=to_keep
                        %     sig_p.(stim{1}).([a{1} '_' f{1}])(end+1,:) = {T(row,:).Source, T(row,:).('Prob>F'){1}};
                        % end

                        % Write the table to a CSV file
                        writetable(T,[obj.homeDir, filesep, 'anova_rabbit.xlsx'], 'Sheet',  [stim{1} '_' a{1} '_' f{1}] );
                        disp(T)

                        % multiple comparisons for main effects
                        [results,~,~,gnames] = multcompare(stats,"Dimension",[1 2],"Display","off");
                        tt = array2table(results,"VariableNames", ...
                            ["Group A","Group B","Lower Limit","A-B","Upper Limit","P-value"]);
                        tt.("Group A")=gnames(tt.("Group A"));
                        tt.("Group B")=gnames(tt.("Group B"));

                        % add to sig_p struct
                        to_keep = find(results(:,end)<.05).';
                        for row=to_keep
                            group_a = tt(row,:).('Group A');
                            group_b = tt(row,:).('Group B');
                            out_string = obj.string_split_helper(group_a, group_b);
                            sig_p.(stim{1}).([a{1} '_' f{1}])(end+1,:) = {out_string, tt(row,:).('P-value')};
                        end                   

                        writetable(tt,[obj.dataDir, filesep, 'anova_rabbit.xlsx'], 'Sheet',  [stim{1} '_' a{1} '_' f{1}], 'Range', 'A8');

                      
                    end
                end
            end
            save([obj.dataDir, filesep, 'anova_sig_p.mat'], 'sig_p')
        end % end of function doANOVA

        function out_string = string_split_helper(obj, in_string1, in_string2)
            split1 = strsplit(in_string1{1}, {'=',','});
            split2 = strsplit(in_string2{1}, {'=',','});

            switch split1{2}
                case '0'
                    split1_loc = 'BS';
                case '1'
                    split1_loc = 'CTRL';
            end

            switch split1{4}
                case '0'
                    split1_beep = 'B0';
                case '2'
                    split1_beep = 'B2';
                case '3'
                    split1_beep = 'B3';
            end

            switch split2{2}
                case '0'
                    split2_loc = 'BS';
                case '1'
                    split2_loc = 'CTRL';
            end

            switch split2{4}
                case '0'
                    split2_beep = 'B0';
                case '2'
                    split2_beep = 'B2';
                case '3'
                    split2_beep = 'B3';
            end

            out_string = [split1_loc '_' split1_beep '/' split2_loc '_' split2_beep];

        end % end of function string_split_helper(string)

        function [sigPos, P] = getRankSumP(obj, df_bs, df_ctrl, fStr, eStr)
            % Comparisons done here:
            % within condition: bs vs ctrl
            % between condition:
            % - B0 vs B2 (bs, ctrl)
            % - B0 vs B3 (bs, ctrl)
            % - B2 vs B3 (bs, ctrl)
            % save P if <.05, otherwise leave as blank ''

            sigPos={}; P=[]; offset = .1;
            combs = nchoosek(1:3,2);

            % WITHIN condition
            fprintf('\n=========Blind Spot vs Control=========\n')

            for col=1:3
                p = ranksum(df_bs{col}, df_ctrl{col});
                if p<.05
                    P(end+1) = p;
                    sigPos(end+1)={[col-offset, col+offset]};
                end
                if p < 005 && p >= 0.01
                    sigStr ='SIG*: ';
                elseif p < 0.01
                    sigStr = 'SIG**: ';
                elseif p> 0.05
                    sigStr = 'N.S.: ';
                end
                fprintf('%s %s, eye = %s, p = %d\n', sigStr, fStr, eStr, p)
            end


            % BETWEEN condition
            fprintf('\n=========No of Beeps=========\n')
            for c=1:length(combs)
                % bs
                % grp1 = obj.filterFields(df_bs, combs(c,1), 'rmSID', true, 'returnArr', true);
                % grp2 = obj.filterFields(df_bs, combs(c,2), 'rmSID', true, 'returnArr', true);
                p = ranksum(df_bs{combs(c,1)}, df_bs{combs(c,2)});
                if p<.05
                    P(end+1) = p;
                    sigPos(end+1)={[combs(c,1)-offset, combs(c,2)-offset]};
                end
                if p < 0.05 && p >= 0.01
                    sigStr ='SIG*: ';
                elseif p < 0.01
                    sigStr = 'SIG**: ';
                elseif p> 0.05
                    sigStr = 'N.S.: ';
                end
                fprintf('BS: %s %s vs %s, eye = %s, p = %d\n', sigStr, [fStr 'B' num2str(combs(c,1))], ...
                    [fStr 'B' num2str(combs(c,2))], eStr, p)


                % ctrl
                % grp1 = obj.filterFields(df_ctrl, combs(c,1), 'rmSID', true, 'returnArr', true);
                % grp2 = obj.filterFields(df_ctrl, combs(c,2), 'rmSID', true, 'returnArr', true);
                p = ranksum(df_ctrl{combs(c,1)}, df_ctrl{combs(c,2)});
                if p<.05
                    P(end+1) = p;
                    sigPos(end+1)={[combs(c,1)+offset, combs(c,2)+offset]};
                end
                if p < 0.05 && p >= 0.01
                    sigStr ='SIG*: ';
                elseif p < 0.01
                    sigStr = 'SIG**: ';
                elseif p> 0.05
                    sigStr = 'N.S.: ';
                end
                fprintf('CTRL: %s %s vs %s, eye = %s, p = %d\n', sigStr, [fStr 'B' num2str(combs(c,1))], ...
                    [fStr 'B' num2str(combs(c,2))], eStr, p)
            end            

        end % end of function getRankSumP
        
        %% helper functions 
        function s = filterRows(obj, s, varargin)
            if (~isempty(varargin))
                for c=1:length(varargin)
                    if ischar(varargin{c})
                        switch varargin{c}
                            case {'type'}
                                type = varargin{c+1};
                                s = obj.allData.grouped.(type);
                            % case {'group'}
                            %     grp = varargin{c+1};
                            %     gid_cond = cellfun(@(x) contains(x, grp), {s.group});
                            %     s = s(gid_cond);
                            case {'glasses'}
                                gls = varargin{c+1};
                                glasses_cond = arrayfun(@(x) (x == gls), [s.glasses]);
                                s = s(glasses_cond);
                            case {'eye'}
                                e = varargin{c+1};
                                eye_cond = cellfun(@(x) strcmp(x, e), {s.eye});
                                s = s(eye_cond);
                            case {'sid'}
                                sid = varargin{c+1};
                                sid_cond = cellfun(@(x) strcmp(x, sid), {s.SID});
                                s = s(sid_cond);
                        end % switch
                    end
                end % for
            end % if

        end % end of function filterRows
        
        function s = filterFields(obj, s, keep_cond, varargin)
            
            fields = fieldnames(s);
            matchingFields = fields(contains(fields, keep_cond));
            fieldsToKeep = [{'SID'}, matchingFields.'];
            s = rmfield(s, setdiff(fieldnames(s), fieldsToKeep));

            if (~isempty(varargin))
                for c=1:length(varargin)
                    if ischar(varargin{c})
                        switch varargin{c}
                            case {'rmSID'}
                                if (varargin{c+1})
                                    s = rmfield(s, 'SID');
                                end
                            case {'returnArr'}
                                if (varargin{c+1})
                                    temp = struct2array(s);
                                    s = reshape(temp, length(fieldnames(s)), obj.N);
                                end                            
                        end % switch
                    end
                end % for
            end % if

        end % end of function filterFields
        
        function makeSchematicsBlock(obj, xStart, xEnd, yStart, yEnd, lineStyle, lineWeight, timeTxt, numFontSize, msPadding)
            % vertical lines
            plot([xStart xStart], [yStart, yEnd], lineStyle, 'LineWidth', lineWeight); hold on
            plot([xEnd xEnd], [yStart, yEnd], lineStyle, 'LineWidth', lineWeight); hold on
            % horizontal line
            plot([xStart, xEnd], [yEnd yEnd], lineStyle, 'LineWidth', lineWeight);
            % white horizontal line to cover time line (for aesthetics)
            plot([xStart+.02, xEnd-.02], [yStart yStart], 'w-', 'LineWidth', lineWeight); hold on
            % text string for timing
            text(xStart-.5, yEnd+msPadding, timeTxt, 'FontSize', numFontSize);

        end % end of function makeSchematicsBlock

        function sigPos = create_sigPos(obj, pair, offset)
            str = strsplit(pair, {'/'});
            sigPos = [];
            for n=1:length(str)
                if contains(str{n},'BS')
                    sigPos(n) = -offset;
                else
                    sigPos(n) = +offset;
                end

                if contains(str{n},'0')
                    sigPos(n) = sigPos(n)+1;
                elseif contains(str{n},'2')
                    sigPos(n) = sigPos(n)+2;
                elseif contains(str{n},'3')
                    sigPos(n) = sigPos(n)+3;
                end
            end
        end % end of function create_sigPos
    end


end