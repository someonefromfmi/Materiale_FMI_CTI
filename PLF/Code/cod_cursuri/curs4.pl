% Rezolutia SLD
father(eddard, sansa).
father(eddard, jonSnow).

stark(eddard).
stark(catelyn).

stark(X) :- father(Y, X),
            stark(Y).
