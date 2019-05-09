function w = tukeywin(n, r)
%TUKEYWIN Tukey window.
%
% Author: Pablo Pizarro @ppizarror.com, 2017.
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

error(nargchk(1, 2, nargin, 'struct')); %#ok<NCHKN>

% Default value for R parameter.
if nargin < 2 || isempty(r)
    r = 0.500;
end

[n, w, trivialwin] = check_order(n);
if trivialwin, return, end

if r <= 0
    w = ones(n, 1);
elseif r >= 1
    w = hann(n);
else
    t = linspace(0, 1, n)';
    % Defines period of the taper as 1/2 period of a sine wave.
    per = r / 2;
    tl = floor(per*(n - 1)) + 1;
    th = n - tl + 1;
    % Window is defined in three sections: taper, constant, taper
    w = [((1 + cos(pi/per*(t(1:tl) - per))) / 2); ones(th-tl-1, 1); ((1 + cos(pi/per*(t(th:end) - 1 + per))) / 2)];
end