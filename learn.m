function [ categoryClassifier ] = learn( inSet )
    
    [training, validation] = partition(inSet, 0.3, 'randomize');
    bag = bagOfFeatures(inSet);
    categoryClassifier = trainImageCategoryClassifier(training, bag);
    evaluate(categoryClassifier, validation);
    
end