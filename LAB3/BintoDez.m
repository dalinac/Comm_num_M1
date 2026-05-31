function [ValueOut] = BintoDez(ValueIn,BitProZeichen)

ValueOut= bin2dec(reshape(char(ValueIn+'0'),BitProZeichen,[])')'; 