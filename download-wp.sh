#!/usr/bin/env bash

# Download AudioBible ZIP files; 50 languages. Praise Jesus Christ the Son of God for his blood!!! EARTH IS FLAT!!! JESUS CHRIST IS LORD!!!

# https://gist.github.com/FlatEarthTruther/452dd3bbe73484d342763d9301d120d8

languages="
17 - amharic            Amharic - አማርኛ
16 - arabic             Arabic
22 - bengali            Bengali - বাংলা
39 - bulgarian          Bulgarian - Библия
43 - burmese            Burmese - မြန်မာ
13 - cantonese          Chinese - 廣東話 [Cantonese - CUV]
04 - chinese            Chinese - 中文 [Mandarin - CUV]
61 - chinese_cat        思高繁体圣经 [Si Gao Version]
62 - cantonese_cath     思高繁体聖經 [Si Gao Version]
32 - czech              Czech - Český
01 - english            English Audio Bible [kjv]
20 - farsi              Farsi (Persian)
63 - finnish            Finnish - Suomalainen - NT
07 - french             French - Français
09 - german             German - Deutsch
58 - greek              Greek - ελληνική - NT
40 - mod_greek_2        Modern Greek - ελληνική
23 - gujarati           Gujarati - ગુજરાતી
03 - hindi              Hindi - हिंदी भाषा
14 - indonesian         Indonesian [TB] -
10 - italian            Italian - Italiano
12 - japanese           Japanese - 日本語
24 - kannada            Kannada - ಕನ್ನಡ
11 - korean             Korean - 한국의
41 - latin              Latin - Vulgata Latina - NT
42 - luganda            Luganda Audio Bible
25 - malayalam          Malayalam - മലയാളം
28 - marathi            Marathi - मराठी
26 - oriya              Oriya - ଓଡ଼ିଆ
33 - polish             Polish - Polski
02 - portuguese         Portuguese - Português
02 - portuguese-BR      Portuguese - Português - BR
27 - punjabi            Punjabi - ਪੰਜਾਬੀ
34 - romanian           Romanian - Român
08 - russian            Russian - русский
31 - serbian            Serbian - Српски
36 - somali             Somali - Soomaaliga
06 - spanish            Spanish - Español
05 - swahili            Swahili - Kiswahili
64 - swedish            Swedish - Svenska - NT
30 - tamil              Tamil - தமிழ் மொழி
29 - telugu             Telugu - తెలుగు
18 - thai               Thai - ไทย
15 - turkish            Turkish - Türk
65 - turkmen            Turkmen - Turkmenistan - NT
67 - ukrainian          Ukrainian - Yкраїнський
21 - urdu               Urdu
100 - uhygur            Uyghur
19 - vietnamese         Vietnamese - Tiếng Việt
35 - zulu               Zulu - isiZulu";

trap ctrl_c INT

function ctrl_c() {
    echo "Interrupted by user";
    exit 0;
}

if [ "$0" == "-bash" ]; then
    BASEDIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")";
else
    BASEDIR="$(realpath "$(dirname "${0}")")";
fi

if [ "`which xidel`" == "" ]; then
    echo "xidel not found"
    echo "https://github.com/benibela/xidel"
    echo "http://www.videlibri.de/xidel.html"
    echo "brew install xidel"
    exit 1;
fi

if [ "`which curl`" == "" ]; then
    echo "curl not found"
    echo "https://github.com/curl/curl"
    echo "https://curl.haxx.se/"
    echo "brew install curl"
    exit 1;
fi

LANGUAGE="";  # download only the selected language
EXTRACT_ZIP_FILES=false;
REMOVE_ZIP_FILES=false;
SHOW_HELP=false;

function show_help() {
    bin=$(basename $0);
    echo "Usage: ${bin} [-l <language_name_or_number> -U -R -h]";
    echo "";
    echo "Run this command without any parameters to list all languages and numbers.";
    echo "";
    echo "  -l  Language name or number to download zip files of, -l all; to download all of them";
    echo "  -U  Unzip the zip files as they are downloaded; specify to unzip, default: false";
    echo "  -R  Remove zip files after extracting them, only used together with -U param";
    echo "  -h  Show help";
    echo "";
    echo "./${bin} -l all";
    echo "./${bin} -l 08 -U";
    echo "./${bin} -l russian -U";
    exit 0;
}

if [[ "${@}" == *"-"* ]]; then  # if has options
    for ((i=1; i<=$#; i++));
    do
        if [ "${!i}" == "-l" ];
        then ((i++))
            LANGUAGE="${!i}";
        fi
        if [ "${!i}" == "-U" ];
        then
            EXTRACT_ZIP_FILES=true;
        fi
        if [[ "${!i}" == "-R" ]];
        then
            REMOVE_ZIP_FILES=true;
        fi
        if [ "${!i}" == "-h" ];
        then
            SHOW_HELP=true;
        fi
    done;
fi
if [ "${SHOW_HELP}" = true ]; then
    show_help;
fi

if [ "${LANGUAGE}" == "" ]; then
    echo "SELECT ONE BY NUMBER OR LANGUAGE";
    echo "${languages}";
exit 1;
fi

function download_audiobible_zip_files() {
    LANG_NAME="$1";
    LANG_PATH="$2";
    LANG_NUMBER="$(echo ${LANG_PATH} | tr '_' ' ' | awk '{print $1}' | tr '0' ' ' | xargs)";

    echo "${LANG_PATH}" "|" "${LANG_NAME}";

    LANG_URL="${WEBSITE_ROOT_URL}/${LANG_PATH}";

    ZIP_ROOT_URL="http://wpaorg.wordproject.com/bibles/app/audio";

    if [ "${LANG_NAME}" != "" ] && [ "${LANG_PATH}" != "" ] && [ "${LANG_NUMBER}" != "" ]; then
        if [ ! -d "${BASEDIR}/${LANG_NAME}" ]; then
            mkdir "${BASEDIR}/${LANG_NAME}";
        fi

        for book in `seq 66`; do
            if [ "${book}" -lt "10" ]; then
                echo "GET HTML: ${LANG_URL}/b0${book}.htm";
                curl --silent "${LANG_URL}/b0${book}.htm" -o "${BASEDIR}/${LANG_NUMBER}-${book}.htm";
            else
                echo "GET HTML: ${LANG_URL}/b${book}.htm";
                curl --silent "${LANG_URL}/b${book}.htm" -o "${BASEDIR}/${LANG_NUMBER}-${book}.htm";
            fi
            name="$(xidel --extract "//h2/text()|//h2/*/text()" -s "${BASEDIR}/${LANG_NUMBER}-${book}.htm")";
            if [ -f "${BASEDIR}/${LANG_NUMBER}-${book}.htm" ]; then
                rm "${BASEDIR}/${LANG_NUMBER}-${book}.htm";
            fi
            if [ "${name}" != "" ]; then
                echo "DESTINATION: ${LANG_NAME}/${book} - ${name}.zip";
                destination="${BASEDIR}/${LANG_NAME}/${book} - ${name}.zip";
            else
                echo "DESTINATION: ${LANG_NAME}/${book}.zip";
                destination="${BASEDIR}/${LANG_NAME}/${book}.zip";
            fi
            echo "GET ZIP: ${ZIP_ROOT_URL}/${LANG_NUMBER}_${book}.zip";
            curl -L -C - "${ZIP_ROOT_URL}/${LANG_NUMBER}_${book}.zip" -o "${destination}";
            if [ "${EXTRACT_ZIP_FILES}" = true ]; then
                if [ -f "${destination}" ]; then
                    if [ ! -d "${BASEDIR}/${LANG_NAME}/${book} - ${name}" ]; then
                        unzip -o "${destination}" -d "${BASEDIR}/${LANG_NAME}";
                        mv "${BASEDIR}/${LANG_NAME}/${book}" "${BASEDIR}/${LANG_NAME}/${book} - ${name}"
                    fi
                    if [ "${REMOVE_ZIP_FILES}" = true ]; then
                        rm "${destination}";
                    fi
                fi
            fi
        done
    fi
}

WEBSITE_ROOT_URL="https://www.wordproject.org/bibles/audio"

curl --silent "${WEBSITE_ROOT_URL}/" -o "${BASEDIR}/audiobible-languages.htm";
PATHS=$(xidel --extract "//ul[contains(@class, 'list-audio')]/li/a/@href" -s "${BASEDIR}/audiobible-languages.htm");
NAMES=$(xidel --extract "//ul[contains(@class, 'list-audio')]/li/a/text()" -s "${BASEDIR}/audiobible-languages.htm");
if [ -f "${BASEDIR}/audiobible-languages.htm" ]; then
    rm "${BASEDIR}/audiobible-languages.htm";
fi

LANG_NAME="";
LANG_PATH="";

OLD_IFS=$IFS;
IFS=$(echo -en "\n\b");
LANGUAGE_NAMES=();
for name in $NAMES; do
    LANGUAGE_NAMES=( "${LANGUAGE_NAMES[@]}" "${name}" );
done
LANGUAGE_PATHS=();
for path in $PATHS; do
    LANGUAGE_PATHS=( "${LANGUAGE_PATHS[@]}" "${path}" );
done

for idx in "${!LANGUAGE_NAMES[@]}"; do
    if [ "${LANGUAGE}" == "all" ]; then
        LANG_NAME="${LANGUAGE_NAMES[$idx]}";
        LANG_PATH="${LANGUAGE_PATHS[$idx]/\/index.htm/}";
        download_audiobible_zip_files "${LANG_NAME}" "${LANG_PATH}";
    else
        if [[ "${LANGUAGE_NAMES[$idx]}" = *"${LANGUAGE}"* ]] || [[ "${LANGUAGE_PATHS[$idx]}" = *"${LANGUAGE}"* ]]; then
            if [ "${LANG_NAME}" == "" ]; then
                LANG_NAME="${LANGUAGE_NAMES[$idx]}";
                LANG_PATH="${LANGUAGE_PATHS[$idx]/\/index.htm/}";
                download_audiobible_zip_files "${LANG_NAME}" "${LANG_PATH}";
            fi
        fi
    fi
done
IFS=$OLD_IFS;
