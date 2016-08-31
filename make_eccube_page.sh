#!/bin/sh

function camelcase(){
	origStr=$1
	separated=`echo $origStr| sed -e 's/_/ /g'`
	camelStr0=""
	camelStr1=""
	for word in $separated; do
	    substr=`echo "${word:0:1}" | tr '[a-z]' '[A-Z]'`
	    tmp=`echo "${word}" | sed "s/^./${substr}/g"`
	    camelStr0=$camelStr0$tmp
	    if [ "$camelStr1" = "" ]; then
	        camelStr1=$tmp
	    else
	        camelStr1=${camelStr1}$tmp
	    fi
	done

	echo $camelStr1
}
cd $(dirname $0);
SCRIPT_DIR=`pwd`"/"

if [ $# -ne 2 ]; then
echo "2 parameters(dirname,filename) is required."
echo "ex.) ./make_eccube_page.sh products sample_list"
exit 1
fi
if [ ! -d "html/$1" ]; then
echo "Directory $1 does not exist."
exit 1
fi
htmlfilepath="html/$1/$2.php"
if [ -f $htmlfilepath ]; then
echo "File $htmlfilepath already exist"
exit 1
fi
classname="LC_Page_`camelcase $1`_`camelcase $2`"
classfile="$classname.php"
touch $htmlfilepath
cat << EOS > $htmlfilepath
<?php
require_once '../require.php';
require_once CLASS_REALDIR . 'pages/$1/$classfile';
\$objPage = new LC_Page_`camelcase $1`_`camelcase $2`();
\$objPage->init();
\$objPage->process();
?>
EOS

echo "$SCRIPT_DIR$htmlfilepath created."

classfilepath="data/class/pages/$1/$classfile"
if [ -f $classfilepath ]; then
echo "File $SCRIPT_DIR$classfilepath already exist"
exit 1
fi

touch $classfilepath
cat << EOS > $classfilepath
<?php
require_once CLASS_EX_REALDIR . 'page_extends/LC_Page_Ex.php';
class $classname extends LC_Page_Ex
{
    public function init()
    {
        parent::init();
        \$masterData = new SC_DB_MasterData_Ex();
    }
    public function process()
    {
        parent::process();
        \$this->action();
        \$this->sendResponse();
    }
    public function action()
    {
    	\$objQuery =& SC_Query_Ex::getSingletonInstance();
        \$objFormParam = new SC_FormParam_Ex();
        \$this->lfInitParam(\$objFormParam);
        \$objFormParam->setParam(\$_POST);
        \$objFormParam->convParam();

        switch (\$this->getMode()) {
            default:
                break;
        }

        \$this->arrForm = \$objFormParam->getHashArray();

    }
    public function lfInitParam(&\$objFormParam)
    {
        //\$objFormParam->addParam('ほげID', 'hoge_id', INT_LEN, 'n', array('NUM_CHECK','EXIST_CHECK', 'MAX_LENGTH_CHECK'));
        //\$objFormParam->addParam('ほげ名', 'hoge_name', STEXT_LEN, 'aKV', array('EXIST_CHECK', 'SPTAB_CHECK', 'MAX_LENGTH_CHECK'));
    }

    public function lfCheckError(&\$objFormParam)
    {
        \$arrErr = \$objFormParam->checkError();
    }
}
?>
EOS
echo "$SCRIPT_DIR$classfilepath created."
templatefilepath="data/Smarty/templates/default/$1/$2.tpl"
if [ -f $templatefilepath ]; then
echo "File $SCRIPT_DIR$templatefilepath already exist"
exit 1
fi
touch $templatefilepath
cat << EOS > $templatefilepath
$1 $2
EOS

echo "$SCRIPT_DIR$templatefilepath created."

sql="INSERT INTO dtb_pagelayout (device_type_id ,page_id ,page_name ,url ,filename ,header_chk ,footer_chk ,edit_flg ,author ,description ,keyword ,update_url ,create_date ,update_date ,meta_robots) "
sql=$sql"SELECT '10',  max(page_id)+1,  'HOGE page',  '$1/$2.php',  '$1/$2',  '1',  '1',  '2', NULL , NULL , NULL , NULL ,  now(),  now(), NULL FROM dtb_pagelayout WHERE device_type_id=10"

echo "please execute this query to add pagelayout."
echo "------------------------------------------"
echo $sql
echo "------------------------------------------"

echo "script finished."
