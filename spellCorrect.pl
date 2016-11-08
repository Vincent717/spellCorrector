remember(a,0.05).
remember(the,0.03).
remember(banana,0.005).

splits(Word,I,Acc,Spl) :- 
					string_length(Word,Len),
					I < Len,
					sub_string(Word,0,I,_,L),
					sub_string(Word,I,_,0,R),
					append(Acc,[[L,R]],Tmp),
					NewI is I + 1,
					splits(Word,NewI,Tmp,Spl).
splits(Word,_,Acc,Acc).

deletes([],[]).
deletes([[H,T]|WT],[RH|RT]) :- 
							sub_string(T,1,_,0,Tmp),
							string_concat(H,Tmp,RH),
							deletes(WT,RT).

transposes([],[]).
transposes([[H,T]|WT],[RH|RT]) :-
								string_length(T,Len),
								Len > 1,
								sub_string(T,0,1,_,FstChar),
								sub_string(T,1,1,_,SndChar),
								sub_string(T,2,_,0,Rest),
								multiConcat([H,SndChar,FstChar,Rest],'',RH),
								transposes(WT,RT).
transposes(A,[]).


getLetter(0,'a').
getLetter(1,'b').
getLetter(2,'c').
getLetter(3,'d').
getLetter(4,'e').
getLetter(5,'f').
getLetter(6,'g').
getLetter(7,'h').
getLetter(8,'i').
getLetter(9,'j').
getLetter(10,'k').
getLetter(11,'l').
getLetter(12,'m').
getLetter(13,'n').
getLetter(14,'o').
getLetter(15,'p').
getLetter(16,'q').
getLetter(17,'r').
getLetter(18,'s').
getLetter(19,'t').
getLetter(20,'u').
getLetter(21,'v').
getLetter(22,'w').
getLetter(23,'x').
getLetter(24,'y').
getLetter(25,'z').


addLetter(L,R,I,Acc,AfterAdds) :-
								I < 26, 
								getLetter(I,Letter),
								multiConcat([L,Letter,R],'',NewWord),
								append(Acc,[NewWord],Tmp),
								NewI is I + 1,
								addLetter(L,R,NewI,Tmp,AfterAdds).
addLetter(_,_,_,Acc,Acc).

replaces([],R,R).
replaces([[H,T]|WT],Acc,R) :-
							sub_string(T,1,_,0,Rest),
							addLetter(H,Rest,0,[],AfterAdds),
							append(Acc,AfterAdds,Tmp),
							replaces(WT,Tmp,R).							

inserts([],R,R).
inserts([[H,T]|WT],Acc,R) :-
							inserts(WT,Tmp,R),
							addLetter(H,T,0,[],AfterAdds),
							append(Acc,AfterAdds,Tmp).

multiConcat([],R,R).
multiConcat([H|T],Acc,R) :- 
						string_concat(Acc,H,Tmp),
						multiConcat(T,Tmp,R).


edits1(Word,Ewords) :- 
					splits(Word,0,[],Spl),
					deletes(Spl,Del),
					transposes(Spl,Tra),
					replaces(Spl,[],Rep),
					inserts(Spl,[],Ins),
					myAppend([Del,Tra,Rep,Ins],[],Ewords).

multiEdits1([],A,A).
multiEdits1([H|T],Acc,E1words) :- 
							multiEdits1(T,R,E1words),
							edits1(H,Ewds),
							append(Ewds,Acc,R).

edits2(Word,E2words) :-
					edits1(Word,E1words),
					multiEdits1(E1words,[],E2words).

known([],[]).
known([H|T],R) :- 
				remember(H,_), 
				append(SR,[H],R),
				known(T,SR).
known([H|T],R) :- known(T,R).


myAppend([],A,A).
myAppend([H|T],A,R) :- 
					myAppend(T,Q,R),
					append(H,A,Q).

candidate(Word,Candidate) :- 
						known([Word],Kword),
						edits1(Word, E1words),
						edits2(Word, E2words),
						known(E1words,KE1words),
						known(E2words,KE2words),
						myAppend([Kword,KE1words,KE2words,[Word]],[],Candidate).

secondLarge([_,TF],[_,TS]) :- TS >= TF.

myMax([],A,A).
myMax([H|T],A,Max) :- 
					secondLarge(H,A),
					myMax(T,A,Max).
myMax([H|T],A,Max) :-
					secondLarge(A,H),
					myMax(T,H,Max).

correction(Word, Correct) :- 
						myMax(Candidate,[none,0],Correct),
						candidate(Word,Candidate).
