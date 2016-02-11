function [ categoryClassifier ] = learn( inSet )

    bag = bagOfFeatures(inSet);
    categoryClassifier = trainImageCategoryClassifier(trainingSets, bag);
    
end