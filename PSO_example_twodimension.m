% Particle swarm optimization 
% 2D problem
% The program is using object oriented program at MATLAB
% Jia LIU Ph.D student, INSA de Lyon
% Supervisor Regis Orobtchouk, INSA de Lyon
%% INITIALIZE MATLAB 
close all; 
clear all; 
clear classes;
addpath(genpath('D:\Gitcode\ParticleSwarmOpt'));
clc
% define fitness function
% Fitnessfnc = @griewangksfcn;
Fitnessfnc = @rastrfcn;
% Fitnessfnc = @(x)100*(x(2)-x(1)^2)^2+(1-x(1))^2;
% define the simulation area 
F = PSOField(2,200,[-5.12,5.12;-5.12,5.12]);
% add particles to the area to do the optimization
F.AddParticle(20,0.8,2.05,2.05,0,0,Fitnessfnc);
% turn on 2d demo
F.Show2dDemo
% enable anti-premature input generationThreshold -- fitnessfncThreshold --
% EucliDistanceThreshold
% UseAntiPremature(F,50,0.01,0.1);
% run simulation
RunPSO(F);
F.PlotGbest;
DispGbest(F);
% F.Plot2DFunction(1)