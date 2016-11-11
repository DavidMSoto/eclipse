# TODO: Add comment
# 
# Author: davidmonteagudo
###############################################################################

#metrica
# https://www.kaggle.com/wiki/MeanAveragePrecision

#modelo
#https://www.google.co.uk/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&ved=0ahUKEwjby9LhuIbQAhVhLsAKHVYYDFIQFggcMAA&url=https%3A%2F%2Fweb.stanford.edu%2Fclass%2Fcs124%2Flec%2FIR-part2.pptx&usg=AFQjCNFEe2DJ1xHdY00naIwftI7WhBRW9g&sig2=33bQDqpQNiGaixk1RQnSgw&bvm=bv.137132246,d.ZGg&cad=rja

#evaluacion
#http://nlp.stanford.edu/IR-book/html/htmledition/evaluation-of-ranked-retrieval-results-1.html


# I haven't done these analyses, but I could point you in the right general direction.
# A basic strategy is to consider each product separately and to predict the likelihood 
# of that product being purchased in the final month using a model like logistic regression. 
# A benefit of logistic regression here is that because it minimizes log loss the scores returned by 
# it inherently have a probabilistic interpretation.
# Once you have obtained likelihoods for each product, you can choose the 7 most probable that
# weren't already owned. A simple example of this being done can be found here, where the author 
# does essentially what I described using just the next-to-last month of the data.
