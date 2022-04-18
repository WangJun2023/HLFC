function [Dataset] = get_data(dataset_name)
    %% import the dataset
    switch dataset_name
        case 'Indian_Pines'
            A = importdata('Indian_pines.mat');
            ground_truth = importdata('Indian_pines_gt.mat');
        case 'Salinas'
            A = importdata('Salinas.mat');
            ground_truth = importdata('Salinas_gt.mat');
        case 'Pavia_University'
            A = importdata('PaviaU.mat');
            ground_truth = importdata('PaviaU_gt.mat');    
        case 'KSC'
            A = importdata('KSC.mat');
            ground_truth = importdata('KSC_gt.mat');
        case 'Botswana'
            A = importdata('Botswana.mat');
            ground_truth = importdata('Botswana_gt.mat');
    end
    %% definition and initialization
    A = double(A);
    minv = min(A(:));
    maxv = max(A(:));
    A = double(A - minv) / double(maxv - minv);
    
    %% Generalize the output
    X = permute(A, [3, 1, 2]);
    X = X(:, :);
    Dataset.X = X; 
    Dataset.A = A;
    Dataset.ground_truth = ground_truth;
end