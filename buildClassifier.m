function [ classifier ] = buildClassifier( inSet )
% BUILDCLASSIFIER builds a Guassian SVM classifier from a Visal Bag of
% Words trained from 80% of the image set.
% Input: Image set with 3 catagories.
% Output: Image Classifier 

    [training, validation] = partition(inSet, 0.8, 'randomize');                        % Splits the image set into a training a validation set.      
    bag = bagOfFeatures(inSet);                                                         % Builds a Visual Bag of Words from the training set. 
    svm = templateSVM('KernelFunction', 'gaussian');                                    % Creates the template for the SVM with a Guassian kernel.
    classifier = trainImageCategoryClassifier(training, bag, 'LearnerOptions', svm);    % Trains the SVM using the bag of words and the training set.
    evaluate(classifier, validation);                                                   % Evaluates the SVM using the validation image set.
end