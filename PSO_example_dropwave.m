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
Fitnessfnc = @(x) -(1 + cos(12*norm(x(1:2))))/(0.5*x(1:2)*x(1:2)'+2);
% Fitnessfnc = @(x)100*(x(2)-x(1)^2)^2+(1-x(1))^2;
% define the simulation area F = PSOField(dimension,iteration generation,[x limit;y limit]);
F = PSOField(2,200,[-2,2;-2,2]);
% add particles to the area to do the optimization inercoeff,cogcoeff,soccoeff
% F.AddParticle(particle number,inercoeff,cogcoeff,soccoeff,coeffkai,coeffinercoeff,Fitnessfnc);
% the inercoeff coule be region 
F.AddDiverseParticle(20,[0.8,1.2],2.05,2.05,0,0,Fitnessfnc);
% turn on 2d demo
F.Show2dDemo
% enable anti-premature input generationThreshold -- fitnessfncThreshold --
% EucliDistanceThreshold
% UseAntiPremature(F,100,0.01,0.1);
% run simulation set(0,'ShowHiddenHandles','on'); delete(get(0,'Children'))
% ShowWaitbar(F)
RunPSO(F);
F.PlotGbest
% F.Plot2DFunction(1)