% Particle swarm optimization 
% multi-dimensional problem
% The program is using object oriented program at MATLAB
% Jia LIU Ph.D student, INSA de Lyon
% Supervisor Regis Orobtchouk, INSA de Lyon
%% INITIALIZE MATLAB 
close all; 
clear all; 
clear classes;
addpath(genpath('D:\Gitcode\ParticleSwarmOpt'));
clc
%%
% define fitness function
% Fitnessfnc = @rosenbrocksfcn;
% Fitnessfnc = @schwefelfcn;
% Fitnessfnc = @ackleyfcn;
% Fitnessfnc = @rosenfcn;
Fitnessfnc = @rastrfcn;
% define the simulation area 
% F = PSOField(4,500,[-4,4;-4,4;-5,7;-9,10]);
% F = PSOField(5,5000,[-500,500;-500,500;-500,500;-500,500;-500,500]); %SCHWEFEL
% F = PSOField(5,1000,[-32.768, 32.768;-32.768, 32.768;-32.768,
% 32.768;-32.768, 32.768;-32.768, 32.768]);     %ACKLEY FUNCTION
% F = PSOField(5,5000,[-5, 10;-5, 10;-5, 10;-5, 10;-5, 10]);    %ROSENBROCK 
F = PSOField(10,2000,[-5.12,5.12;-5.12,5.12;-5.12,5.12;-5.12,5.12;-5.12,5.12;-5.12,5.12;-5.12,5.12;-5.12,5.12;-5.12,5.12;-5.12,5.12]); %RASTRIGIN
% add particles to the area to do the optimization
% F.AddParticle(70,0.8,2.05,2.05,0,0,Fitnessfnc);
% add diversity particles 
F.AddDiverseParticle(50,[0.8,1.2],2.05,2.05,0,0,Fitnessfnc);
% turn on 2d demo 
% for high dimensions the visualization is not possible
% F.Show2dDemo
% enable anti-premature
% UseAntiPremature(F,50,0.05,0.1);
% run simulation
RunPSO(F);
F.PlotGbest
DispGbest(F)
% F.Plot2DFunction(1)