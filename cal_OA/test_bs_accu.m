function [accu,Classify_map] = test_bs_accu(band_set, Dataset, classifier_type)
warning('off');
for iter = 1 : 3
    switch(classifier_type)
        case 'EPF'
            [OA(iter),MA(iter),Kappa(iter),test_SL,predict_label] = EPF_Classifier(Dataset, band_set);
        case 'KSRC'
            [OA(iter),MA(iter),Kappa(iter),test_SL,predict_label] = KSRC_Classifier(Dataset, band_set);
        case 'LBP'
            [OA(iter),MA(iter),Kappa(iter),test_SL,predict_label] = LBP_Classifier(Dataset, band_set);
        case 'SVM'
            [OA(iter),MA(iter),Kappa(iter),test_SL,predict_label] = SVM_Classifier(Dataset, band_set);
        case 'CART'
            [OA(iter),MA(iter),Kappa(iter),test_SL,predict_label] = CART_Classifier(Dataset, band_set);
        case 'KNN'
            [OA(iter),MA(iter),Kappa(iter),test_SL,predict_label] = KNN_Classifier(Dataset, band_set);
        case 'LDA'
            [OA(iter),MA(iter),Kappa(iter),test_SL,predict_label] = LDA_Classifier(Dataset, band_set);
        case 'NB'
            [OA(iter),MA(iter),Kappa(iter),test_SL,predict_label] = NB_Classifier(Dataset, band_set);
        case 'RF'
            [OA(iter),MA(iter),Kappa(iter),test_SL,predict_label] = RF_Classifier(Dataset, band_set);
    end
end
accu.OA = mean(OA);
accu.MA = mean(MA);
accu.Kappa = mean(Kappa);

accu.STDOA = std(OA);
accu.STDMA = std(MA);
accu.STDKappa = std(Kappa);

[M,N,B] = size(Dataset.A);

Classify_map = Dataset.ground_truth(:);
Classify_map(test_SL(1,:)) = predict_label;
Classify_map = reshape(Classify_map,[M N]);

end