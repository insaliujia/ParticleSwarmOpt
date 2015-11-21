classdef PSOParticle < handle 
    % This class take care of the particles
    
    properties (SetAccess = protected)
        name                % particle name presented by numbers
        generation          % generation of this particle
        velocity            % velocity of particle
        position            % position of particle
        score               % score of this particle 
        nvars               % number of variables
        pbest               % local best solution
        pbestscore               % score of fitness function
        inercoeff           % inertia coefficient
        cogcoeff            % cognitive coefficent
        soccoeff            % social coefficient
        kai                % constriction term
        coeffkai               % coefficient of kai which controls the convergence
        coeffinercoeff       % coefficient of inertia coefficient which controls the convergence
        fitnessfcn              % merit function or fitness function
        EucliDistance         % distance between this particle and the global best
%         randnum_1           % random for cognitive coefficent
%         randnum_2           % random for social coefficient
    end
    

    
    methods
        function particle = PSOParticle(num,velocity,position,pbest,score,inercoeff,cogcoeff,soccoeff,coeffkai,coeffinercoeff,fitnessfcn)
            % This functon initialize particle
            % input num--particle name; velocity--particle velocity; position--particle position
            % pbest--local best;inercoeff--inertia coefficient;cogcoeff--cognitive coefficent
            % soccoeff--social coefficient
            particle.name = num;
            particle.velocity = velocity;
            particle.position = position;
            particle.nvars = numel(position);
            particle.pbest = pbest;
            particle.pbestscore = score;
            particle.inercoeff = inercoeff;
            particle.cogcoeff = cogcoeff;
            particle.soccoeff = soccoeff;
            particle.coeffkai = coeffkai;
            particle.coeffinercoeff = coeffinercoeff;
            particle.kai = 2/abs(2-(cogcoeff+soccoeff)-sqrt((cogcoeff+soccoeff)^2-4*(cogcoeff+soccoeff)));
            particle.fitnessfcn = fitnessfcn;
        end
        
        function MoveParticle(particle,gbest,generation,totalgeneration)
            % input the global best; coeff--coefficient to constrain
            % velocity at the end of simulation; generation--corrent
            % generatin; totalgeneration--total generation
            % inertia term controls how quickly a particle will change direction
            % cognitive term controls the tendency of a particle to move toward the best solution observed by that particle
            % social term controls the tendancy of a particle to move toward the best solution observed by any of the particles.
            Particlenum = numel(particle);
            dimension = particle(1).nvars;
            Coeffkai = particle(1).coeffkai;
            coeffInercoeff = particle(1).coeffinercoeff;
%             dimension = numel(particle(1).position);
            for n = 1:Particlenum
                UpdateKai(particle(n),Coeffkai,generation,totalgeneration);
                UpdateInercoeff(particle(n),coeffInercoeff,generation,totalgeneration);
                r1 = rand(1,dimension);
                r2 = rand(1,dimension);
                particle(n).velocity = particle(n).inercoeff*particle(n).velocity+...        % inertia term
                    particle(n).cogcoeff*r1.*(particle(n).pbest-particle(n).position)+...     % cognitive term
                    particle(n).soccoeff*r2.*(gbest-particle(n).position);                 % social term
                particle(n).position = particle(n).position + particle(n).kai*particle(n).velocity;
                % apply the bound condiction 
%                 for m = 1 : particle(n).nvars
%                 particle(n).position(m) = min()
%                 
%                 end
%                 UpdateInercoeff(particle(n),0.1,generation,totalgeneration);
            end
        end
        
        function ApplyBounds(particle,bounds)
            % This function Apply bound to the PSO
            Particlenum = numel(particle);
            Variablenum = particle(1).nvars;
            for i = 1:Particlenum
                for j = 1 : Variablenum
                    particle(i).position(j) = min(bounds(2,j),max(bounds(1,j),particle(i).position(j)));
                end
            end       
        end        
        
        function UpdateKai(particle,coeffkai,generation,totalgeneration)
            % This function is responsible to update kai in order to
            % enhance the convergence at the end of the all generations
            particle.generation = generation;
            particle.kai = particle.kai - coeffkai*((generation-1)/(totalgeneration-1));
        end
        
        function UpdateInercoeff(particle,coeffInercoeff,generation,totalgeneration)
            % This function update the inertia term to accelerate
            % convergence
            particle.inercoeff = particle.inercoeff - coeffInercoeff*((generation-1)/(totalgeneration-1));
        end
        
        function SetPbest(particle)
            Particlenum = numel(particle);
            for n = 1:Particlenum
                if particle(n).score < particle(n).pbestscore
                    particle(n).pbestscore = particle(n).score;
                    particle(n).pbest = particle(n).position;
                end
            end
        end
        
        function [ParticleScore,ParticlePosition] = GetParticle(particle)
            Particlenum = numel(particle);
            ParticleScore = zeros(Particlenum,1);
            ParticlePosition = zeros(Particlenum,particle(1).nvars);
            for n = 1:Particlenum
                ParticleScore(n) = particle(n).pbestscore;
                ParticlePosition(n,:) = particle(n).pbest;
            end
        end
            
        function EvaluateFitnessFcn(particle)
            % This function caculate the fitness function and get the socre
            FitnessFcn = particle(1).fitnessfcn ;
            Particlenum = numel(particle);
            for n = 1:Particlenum
                particle(n).score = FitnessFcn(particle(n).position);
            end
        end
        
        function EuclideanDistance(particle,gbest,scale)
            % This function caculates the Euclidean distance of the
            % particles
            Particlenum = numel(particle);
            Weight = (scale(2,:) - scale(1,:)).^2;
            for n = 1:Particlenum
                V = particle(n).position - gbest;
                particle(n).EucliDistance = sqrt(sum((V.^2)./Weight));
            end
        end
        
        function RestartParticle(particle,bounds,EucliDistanceThreshold)
           % This function will re-position the particles that stucked in the local best
           FitnessFcn = particle(1).fitnessfcn ;
           Particlenum = numel(particle);
           for n = 1:Particlenum
              if  particle(n).EucliDistance < EucliDistanceThreshold 
                  particle(n).position = bounds(1,:) + (bounds(2,:) - bounds(1,:)).*rand(1,particle(n).nvars);
                  particle(n).score = FitnessFcn(particle(n).position);
                  particle(n).pbest = particle(n).position;
              end
               
           end
           
        end
        
        
        
    end

end