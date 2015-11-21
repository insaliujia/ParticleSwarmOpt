classdef PSOField < handle
    % This class take care of the working history of particles
    
    properties (SetAccess = protected)
        particlenum             % particle number
        totalgeneration         % generation number
        area                    % area which particles can go (constraints)
        ApplyConstraints = 1    % apply the constraints 
        dimension               % number of variables
        gbest                   % global best
        gbestsocre              % global best parameters
        gbestrecord             % recorded global best
        Demo2d = 0              % control 2d demo
        ApplyAntiPremature = 0  % control function UseAntiPremature
        generationThreshold     % threshold for genneration
        fitnessfncThreshold     % threshold for fitness function
        Stablenum = 0           % stable number for simulation
        EucliDistanceThreshold  % thres hold for Euclidean distance
        ShowProcess = 0            % wait bar flag
        particle                % particles in this field
        
    end
    
    methods 
        
        function psofield = PSOField(dimension,totalgeneration,varargin)
            % This function define the constraints condictions
            % Input area--format will be [low1,high1;low2,high2;...];
            % dimension--dimension of the simualtion space
            % totalgeneration--total generation
            psofield.dimension = dimension;
            psofield.totalgeneration = totalgeneration;
            psofield.gbest = ones(1,dimension)*inf ;
            psofield.gbestsocre = ones(1,1)*inf;
            psofield.gbestrecord = zeros(totalgeneration,3);
            if nargin == 3
                psofield.area = varargin{1}';
            end
        end
        
        function AddParticle(psofield,particlenum,inercoeff,cogcoeff,soccoeff,coeffkai,coeffinercoeff,fitnessfcn)
            % This function add particles to the field
            % Input:method--the way it will generate initial positions of
            % particles, it can be'random' random places, 'specify' user specified places
            psofield.particlenum = particlenum;         % define particle number
            velocity = zeros(1,psofield.dimension);     % define initial speed
            pbest = ones(1,psofield.dimension)*inf ;    % define initial best position
            score = ones(1,1)*inf;                      % define initial score for every position
            
            if ~isempty(psofield.area)
                for n = 1:particlenum
                    position = psofield.area(1,:) + (psofield.area(2,:) - psofield.area(1,:)).*rand(1,psofield.dimension);
                    P(n) = PSOParticle(n,velocity,position,pbest,score,inercoeff,cogcoeff,soccoeff,coeffkai,coeffinercoeff,fitnessfcn);
                end
            elseif isempty(psofield.area)
                for n = 1:particlenum
                    position = 100*rand(1,psofield.dimension);
                    P(n) = PSOParticle(n,velocity,position,pbest,score,inercoeff,cogcoeff,soccoeff,coeffkai,coeffinercoeff,fitnessfcn);
                end
            else
                error('check the simulation area')
            end  
            psofield.particle = P;
        end
        
        
        function AddDiverseParticle(psofield,particlenum,inercoeff,cogcoeff,soccoeff,coeffkai,coeffinercoeff,fitnessfcn)
            % This function add particles with diversity
            if numel(inercoeff) == 2
                psofield.particlenum = particlenum;         % define particle number
                velocity = zeros(1,psofield.dimension);     % define initial speed
                pbest = ones(1,psofield.dimension)*inf ;    % define initial best position
                score = ones(1,1)*inf;                      % define initial score for every position
                for n = 1:particlenum
                    inercoeff_particle = inercoeff(1) + (inercoeff(2) - inercoeff(1))*rand(1,1);
                    position = psofield.area(1,:) + (psofield.area(2,:) - psofield.area(1,:)).*rand(1,psofield.dimension);
                    P(n) = PSOParticle(n,velocity,position,pbest,score,inercoeff_particle,cogcoeff,soccoeff,coeffkai,coeffinercoeff,fitnessfcn);
                end
            else
                error('check intercoeff');
            end
            psofield.particle = P;
        end
            
        function SetGbest(psofield,k)
            % This function update the global best
            [ParticleScore,ParticlePosition] = psofield.particle.GetParticle;
            [Pbestmin, index] = min(ParticleScore);              % find the minmum particle best for this generation
            if Pbestmin < psofield.gbestsocre
                psofield.gbestsocre = Pbestmin;
                psofield.gbest = ParticlePosition(index,:);
            end
            psofield.gbestrecord(k,1) = psofield.gbestsocre;
            psofield.gbestrecord(k,2) = sum(ParticleScore)/psofield.particlenum;
            psofield.gbestrecord(k,3) = index;
        end
        
        function Show2dDemo(psofield)
            % This function will control the 2d demo
            psofield.Demo2d = 1;
            
        end

        function DisableConstraints (psofield)
            % This function disables constraints 
            psofield.Demo2d = 0;
        end
        
        function ShowWaitbar(psofield)
           % This function is the flag for waitbar
           psofield.ShowProcess = 1;
        end
            
        
        function RunPSO(psofield)
            % This function run the PSO simulation
            if psofield.ShowProcess == 1
                h = waitbar(0,'1','Name','PSO Caculating...',...
                    'CreateCancelBtn',...
                    'setappdata(gcbf,''canceling'',1)');
                setappdata(h,'canceling',0)
            end
            TotalGeneration = psofield.totalgeneration;
            for k = 1 : TotalGeneration
                EvaluateFitnessFcn(psofield.particle);
                SetPbest(psofield.particle);
                SetGbest(psofield,k)
                if psofield.Demo2d == 1
                    Plot2DFunction(psofield,k)    
                end
                if psofield.ApplyAntiPremature == 1
                    DealPremature(psofield,k)
                end
                GlobalBest = psofield.gbest;
                MoveParticle(psofield.particle,GlobalBest,k,TotalGeneration)
                if psofield.ApplyConstraints == 1
                    ApplyBounds(psofield.particle,psofield.area);
                end
                
                if psofield.ShowProcess == 1
                    waitbar(k/TotalGeneration,h,'I am working, please don''t disturb me ...');
                    if getappdata(h,'canceling')
                        delete(h)
                        break
                    end
                end
            end
            if  psofield.ShowProcess == 1
                delete(h)
            end

        end
        
        
        function UseAntiPremature(psofield,generationThreshold,fitnessfncThreshold,EucliDistanceThreshold)
            % This function ables Anti premature function
            psofield.ApplyAntiPremature = 1;
            psofield.generationThreshold = generationThreshold;
            psofield.fitnessfncThreshold = fitnessfncThreshold;
            psofield.EucliDistanceThreshold = EucliDistanceThreshold;
        end
        
        
        function DealPremature(psofield,Generation)
            % this function will check the premature state and deal with it
            if Generation > 1
                if (psofield.gbestrecord(Generation - 1,1) - psofield.gbestrecord(Generation,1))...
                        < psofield.fitnessfncThreshold
                    psofield.Stablenum = psofield.Stablenum + 1;
                end
            end
            
            if psofield.Stablenum > psofield.generationThreshold
                EuclideanDistance(psofield.particle,psofield.gbest,psofield.area)
                RestartParticle(psofield.particle,psofield.area,psofield.EucliDistanceThreshold)
                SetGbest(psofield,Generation)
                psofield.Stablenum = 0;
            end
        end
               
        function PlotGbest(psofield)
            % plot the gbest
            figure1 = figure;
            % Create axes
            axes1 = axes('Parent',figure1,'FontWeight','demi','FontSize',12);
            box(axes1,'on');
            hold(axes1,'all');
            plot(psofield.gbestrecord(:,1),'--bo','linewidth',2);
            hold on;
            plot(psofield.gbestrecord(:,2),'--r*','linewidth',2);
            hold off
            title('Evelution of the Global Best','FontWeight','bold','FontSize',14);
            xlabel('generations','FontWeight','demi','FontSize',12);
            ylabel('value of fitness function','FontWeight','demi','FontSize',12);
            legend('Global Best','Mean value');
        end     
        
        function DispGbest(psofield)
            % display gbest on the screen
            disp(['Global best is ' num2str(psofield.gbestsocre)]);
            disp(['At position ', num2str(psofield.gbest)]);
        end
        
        
        function Plot2DFunction(psofield,varargin)
            % This function will plot the 2D optimization problem
            if nargin == 1
                figure
                xbord = psofield.area(:,1);
                ybord = psofield.area(:,2);
                [XX,YY] = meshgrid(xbord(1):(xbord(2)-xbord(1))/100:xbord(2),...
                    ybord(1):(ybord(2)-ybord(1))/100:ybord(2)) ;
                ZZ = zeros(size(XX));
                for i = 1:size(XX,1)
                    for j = 1:size(XX,2)
                        ZZ(i,j) = psofield.particle(1).fitnessfcn([XX(i,j) YY(i,j)]) ;
                    end
                end
                surface(XX,YY,ZZ,'LineStyle','none','FaceAlpha',0.4,...
                    'FaceLighting','gouraud','FaceColor','interp')
                set(gcf,'Colormap',spring)
                view(3)
                axis tight
            end
            if nargin == 2
                [ParticleScore,ParticlePosition] = psofield.particle.GetParticle;
                if varargin{1} == 1
                    figure
                    xbord = psofield.area(:,1);
                    ybord = psofield.area(:,2);
                    [XX,YY] = meshgrid(xbord(1):(xbord(2)-xbord(1))/100:xbord(2),...
                        ybord(1):(ybord(2)-ybord(1))/100:ybord(2)) ;
                    ZZ = zeros(size(XX));
                    for i = 1:size(XX,1)
                        for j = 1:size(XX,2)
                            ZZ(i,j) = psofield.particle(1).fitnessfcn([XX(i,j) YY(i,j)]) ;
                        end
                    end
                    surface(XX,YY,ZZ,'LineStyle','none','FaceAlpha',0.4,...
                        'FaceLighting','gouraud','FaceColor','interp')
                    set(gcf,'Colormap',spring)
                    view(3)
                    axis tight
                    line(ParticlePosition(:,1),ParticlePosition(:,2),...
                        ParticleScore','LineStyle','none',...
                        'Marker','.','Color','blue','Tag','Swarm Locations');
                    pause(0.05);
                else
                    set(findobj(gca,'Tag','Swarm Locations','Type','line'),...
                        'XData',ParticlePosition(:,1),...
                        'YData',ParticlePosition(:,2),...
                        'ZData',ParticleScore')
                    pause(0.05);
                end
                titletxt = sprintf('%d th Generation',varargin{1});
                title(titletxt)
                
            end
            
        end
        
    end
  
    
end