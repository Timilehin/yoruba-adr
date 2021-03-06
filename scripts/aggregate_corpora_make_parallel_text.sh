#! /usr/bin/env bash
# Copyright 2017 iroro orife.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file aggregates raw source text (fully diacritized) and creates train/dev/test splits

set -e

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
echo "Using BASE_DIR=${BASE_DIR}"

SOURCE_BASE_DIR="${BASE_DIR}/../yoruba-text"
echo "Using SOURCE_TEXT_BASE_DIR=${SOURCE_BASE_DIR}"

OUTPUT_DIR=${OUTPUT_DIR:-$BASE_DIR/data}
echo "Writing PREPROCESSED FILES to ${OUTPUT_DIR}"

# setup output dirs with train/dev/test splits
OUTPUT_DIR_TRAIN="${OUTPUT_DIR}/train"
OUTPUT_DIR_DEV="${OUTPUT_DIR}/dev"
OUTPUT_DIR_TEST="${OUTPUT_DIR}/test"

# start afresh each time
rm -rf $OUTPUT_DIR_TRAIN; mkdir $OUTPUT_DIR_TRAIN
rm -rf $OUTPUT_DIR_DEV;   mkdir $OUTPUT_DIR_DEV
rm -rf $OUTPUT_DIR_TEST;  mkdir $OUTPUT_DIR_TEST

SOURCE_FILE_TRAIN="${OUTPUT_DIR_TRAIN}/train.txt"
SOURCE_FILE_DEV="${OUTPUT_DIR_DEV}/dev.txt"
SOURCE_FILE_TEST="${OUTPUT_DIR_TEST}/test.txt"

###############################################################################################################
### FOR LagosNWUspeech_corpus: 4315 lines => 80/10/10 split => train/dev/test => 3452/431/432
echo ""
echo "Using [LagosNWUspeech] SOURCE FILE TRAIN=${SOURCE_FILE_TRAIN}"
head -n 3452 "${SOURCE_BASE_DIR}/LagosNWU/all_transcripts.txt" >>  ${SOURCE_FILE_TRAIN}

echo "Using [LagosNWUspeech] SOURCE FILE TRAIN=${SOURCE_FILE_DEV}"
tail -n 863 "${SOURCE_BASE_DIR}/LagosNWU/all_transcripts.txt" | head -n 431  >> ${SOURCE_FILE_DEV}

echo "Using [LagosNWUspeech] SOURCE FILE TRAIN=${SOURCE_FILE_TEST}"
tail -n 863 "${SOURCE_BASE_DIR}/LagosNWU/all_transcripts.txt" | tail -n 432  >> ${SOURCE_FILE_TEST}
echo "" >> ${SOURCE_FILE_TEST}


###############################################################################################################
### FOR TheYorubaBlog_corpus: 4135 lines => 80/10/10 split => train/dev/test => 3308/413/414
echo ""
echo "Using [TheYorubaBlog] SOURCE FILE TRAIN=${SOURCE_FILE_TRAIN}"
head -n 3308 "${SOURCE_BASE_DIR}/TheYorubaBlog/theyorubablog_dot_com.txt" >>  ${SOURCE_FILE_TRAIN}

echo "Using [TheYorubaBlog] SOURCE FILE TRAIN=${SOURCE_FILE_DEV}"
tail -n 827 "${SOURCE_BASE_DIR}/TheYorubaBlog/theyorubablog_dot_com.txt" | head -n 413  >> ${SOURCE_FILE_DEV}

echo "Using [TheYorubaBlog] SOURCE FILE TRAIN=${SOURCE_FILE_TEST}"
tail -n 827 "${SOURCE_BASE_DIR}/TheYorubaBlog/theyorubablog_dot_com.txt" | tail -n 414  >> ${SOURCE_FILE_TEST}
echo "" >> ${SOURCE_FILE_TEST}


###############################################################################################################
### FOR BibeliYoruba_corpus: 45713 lines => 80/10/10 split => train/dev/test => 36570/4570/4570
echo "" 
echo "Using [BibeliYoruba] SOURCE FILE TRAIN=${SOURCE_FILE_TRAIN}"
head -n 36570 "${SOURCE_BASE_DIR}/Bibeli_Mimo/bibeli_ede_yoruba.txt" >>  ${SOURCE_FILE_TRAIN}

echo "Using [BibeliYoruba] SOURCE FILE TRAIN=${SOURCE_FILE_DEV}"
tail -n 9143 "${SOURCE_BASE_DIR}/Bibeli_Mimo/bibeli_ede_yoruba.txt" | head -n 4571  >> ${SOURCE_FILE_DEV}

echo "Using [BibeliYoruba] SOURCE FILE TRAIN=${SOURCE_FILE_TEST}"
tail -n 9143 "${SOURCE_BASE_DIR}/Bibeli_Mimo/bibeli_ede_yoruba.txt" | tail -n 4571  >> ${SOURCE_FILE_TEST}
echo "" >> ${SOURCE_FILE_TEST}

# Verify split sums are sane: 43330/5415/5417
cat ${SOURCE_FILE_TRAIN} | wc -l
cat ${SOURCE_FILE_DEV}   | wc -l 
cat ${SOURCE_FILE_TEST}  | wc -l


###############################################################################################################
###############################################################################################################
echo "[INFO] make parallel text dataset for yoruba diacritics restoration"

# Write train, dev and test data
${BASE_DIR}/src/make_parallel_text.py --source_file ${SOURCE_FILE_TRAIN} \
  --max_len 20 --output_dir ${OUTPUT_DIR_TRAIN}

${BASE_DIR}/src/make_parallel_text.py --source_file ${SOURCE_FILE_DEV} \
  --max_len 20 --output_dir ${OUTPUT_DIR_DEV}

${BASE_DIR}/src/make_parallel_text.py --source_file ${SOURCE_FILE_TEST} \
  --max_len 20 --output_dir ${OUTPUT_DIR_TEST}

# clean up intermediates, to leave only final parallel text {sources.txt, targets.txt}
rm ${SOURCE_FILE_TRAIN} ${SOURCE_FILE_DEV} ${SOURCE_FILE_TEST} 

# # Create Vocabulary
# ${BASE_DIR}/bin/tools/generate_vocab.py  < ${OUTPUT_DIR_TRAIN}/sources.txt  > ${OUTPUT_DIR_TRAIN}/vocab.sources.txt
# echo "Wrote ${OUTPUT_DIR_TRAIN}/vocab.sources.txt"

# ${BASE_DIR}/bin/tools/generate_vocab.py < ${OUTPUT_DIR_TRAIN}/targets.txt > ${OUTPUT_DIR_TRAIN}/vocab.targets.txt
# echo "Wrote ${OUTPUT_DIR_TRAIN}/vocab.targets.txt"