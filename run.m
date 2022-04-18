clear all
clc
dataset_names = {'Indian_Pines', 'KSC', 'Botswana','Salinas'};
classifier_names = {'SVM', 'RF', 'KSRC'};
svm_para = {'-c 5000.000000 -g 0.500000 -m 500 -t 2 -q',...
    '-c 10000.000000 -g 16.000000 -m 500 -t 2 -q',...
    '-c 10000 -g 0.5 -m 500 -t 2 -q',...
     '-c 100 -g 16 -m 500 -t 2 -q',...
    }; 
train_ratio = [0.05, 0.01, 0.01, 0.01];

data = {'Indian_Pines-60', 'KSC-58','Botswana-58','Salinas-25'};

ResSavePath = 'HLFC/results/';

dimension = [5, 5, 5, 5];

warning off;

for dataset_id = 1
    Dataset = get_data(dataset_names{dataset_id});
    Dataset.svm_para = svm_para{1, dataset_id};
    Dataset.train_ratio = train_ratio(dataset_id);
    dataName = [data{dataset_id} '.mat'];
    load(dataName);
        for classifier_id = 2
            [OA,MA,Kappa] = HLFC(Dataset,X1,classifier_names{classifier_id}, dimension(dataset_id));
            resFile = [ResSavePath data{dataset_id},'-',classifier_names{classifier_id},'.mat'];
              
            save(resFile, 'OA','MA','Kappa');
        end
end