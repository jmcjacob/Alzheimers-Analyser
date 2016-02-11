function [ categoryClassifier ] = learn( inSet )

    bag = bagOfFeatures(inSet);
    categoryClassifier = trainImageCategoryClassifier(inSet, bag);
    
end