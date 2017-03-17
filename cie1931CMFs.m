function [T_xyz, S_xyz] = cie1931CMFs()

    T_xyz = csvread('ciexyz31.csv')';
    S_xyz = [380, 5, 81];
    T_xyz = 683 * T_xyz;
    
end