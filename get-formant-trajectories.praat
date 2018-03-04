######################################
# get-formant-trajectories.praat
######################################
# MIT License
#
# Copyright (c) 2018 Stefano Coretta
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
######################################
# This script extracts formants and F0 values from vowels as a time series.
#
# Input: a .wav file and a TextGrid
# Output: a comma separated file with tidy time series data
#  - file:        name of the file
#  - vowel:       vowel label as it shows in the TextGrid
#  - interval:    interval number (integer) within the vowel duration
#  - f1, f2, f3:  values of the formants in Hertz
#  - f0:          values of the fundamental frequency F0 in Hertz
######################################

form Get formants trajectories
  word Directory ~/Desktop
  word Sound_file file.wav
  real Vowel_tier 1
  word Vowel_label_(or_regex) V
  real Maximum_formant_(Hz) 5500
  real Number_of_formants 5
  comment Take measurements every percent:
  real percent_(%) 10
endform

file_name$ = sound_file$ - ".wav"
result_header$ = "file,vowel,interval,f1,f2,f3,f0"
result_file$ = "'directory$'/'file_name$'-trajectories.csv"
writeFileLine: result_file$, result_header$

sound = Read from file: "'directory$'/'sound_file$'"
textgrid = Read from file: "'directory$'/'file_name$'.TextGrid"
intervals = Get number of intervals: vowel_tier

for interval from 1 to intervals
  selectObject: textgrid
  vowel$ = Get label of interval: vowel_tier, interval
  match = index_regex(vowel$, vowel_label$)

  if match > 0
    vowel_start = Get start time of interval: vowel_tier, interval
    vowel_end = Get end time of interval: vowel_tier, interval
    vowel_duration = vowel_end - vowel_start
    duration_nth = vowel_duration / percent

    selectObject: sound
    sound_vowel = Extract part: vowel_start - 0.5, vowel_end + 0.5, "rectangular", 1, "yes"
    formant = noprogress To Formant (burg): 0, number_of_formants, maximum_formant, 0.025, 50
    selectObject: sound
    pitch = noprogress To Pitch: 0, 75, 600

    time_points = (100 / percent) - 1

    for time_point from 1 to time_points
      time = vowel_start + (duration_nth * time_point)
      selectObject: formant
      f1 = Get value at time: 1, time, "Hertz", "Linear"
      f2 = Get value at time: 2, time, "Hertz", "Linear"
      f3 = Get value at time: 3, time, "Hertz", "Linear"

      selectObject: pitch
      f0 = Get value at time: time, "Hertz", "Linear"

      result_line$ = "'file_name$','vowel$','time_point','f1','f2','f3','f0'"
      appendFileLine: result_file$, result_line$

    endfor

    removeObject: sound_vowel, formant, pitch

  endif

endfor
