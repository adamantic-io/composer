ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.9.1
docker tag hyperledger/composer-playground:0.9.1 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.hfc-key-store
tar -cv * | docker exec -i composer tar x -C /home/composer/.hfc-key-store

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� \�\Y �=Mo�Hv==��7�� 	�T�n���[I�����hYm�[��n�z(�$ѦH��$�/rrH�=$���\����X�c.�a��S��`��H�ԇ-�v˽�z@���WU�>ޫW�^U��r�b6-Ӂ!K��u�lj����0!��F�������6�rq6������� 0wT���r\���k�m͹oR��)���h����e�r����Q �����7�e��f@�Ȑ�p�K"��\Ga��m�uhGz�!EP-�v/K B`y�Ya���$m�6�&4�R2�-��R�(��md�k�;?�w�/ h���&MÀ��*U�͚�Cz��&WmM�_S(è��	)�cPn�+s�ir[�pq��I�l�M�"D?�6;}���^vM�`Ef�[<nԔB	9a4s�	͖�RFf$ִUh�Q���Ł�& )Z����ۖ������LnZ:#�����#I/�BގТ4d�C$�f��c��X����u6[.�b(����\�����d��A���]�a��ZՆ�-�;��@��<����9L��(!��6�i�N�G�U���eC�����<U@ԉjS#���Wv�Rj�C���:��dQ�_t;�}Bď/-<!�\h��9�"��ǥ�[X��:"��v4B#w^���q���Co��(���s 甌��|���.�m���v�-��?u����il�c���_���_E����N�r̖�@@?y
��Q5�B��.!�7����RRzü���3|�5�:*��馌�}4X~�B�c��>��{��\��`��7��KVN�r>|�Ɲ�A�?�+�?,�����bH�cX��.���_���` +/�7a&̄�^�m��A��9�5nY��y0aȆJ��f�h5ֆ�ia��?X-��|,[k�.�ѵ[��-�a�CF[�h8�F"�⼈�E�?�rN'tS9Q2ZLzkL�l�-\%/)�����V��0�K�C��!�qq�:a&$�VC��}�뱰	�[�3�<ab/!kj�k�@�Ֆ��!�VZ��D�[�B!�۱@����2/�Щ������hx��*��k^���U^�a?fu(��&�+Kʧ.s�׬�D]O�۪݁��?�A�ހ�G!�b�7��c��<Pk�(܆�M׉��a�lC��2ͨ_n
8T?����g�;�*��O��d���g�Vo�6Y`���:�i��%��@*�[�<����-��k�;A6b�t[��$g���¹���`�ܕ��p%{�OS��$C��r/p+n����%q��DY�[�C!mV�$��Ɯ��`�M&�K{��:@�����q�=���}����ی���8I�f�g��+B`kh���%�hc��>������ު�����EQvŖ�D�v�D�]���á
��:]С�@�@*.�44�L�݀� My���S2@�׀46��V� �9���Q~F]h�6?�7?E����oW�������<#,���哗//�J�#zM�r4!��3��á#+�jp19�0f�ǃ��l?f��||���,�?7���˾��2&�?�7{���]������4�x��gr �����jV�lS�)���m��)h-��9 ��4��R�Li�Klf�G�d)S���d��1���VW�W�O��/�1IDQ�#wCL�2ɣ]�T��s��..Uf_�@ �Z��HIwZM\�灃�ϰ�L��;�PPw��y��R`��`"�TF�-W�R娒�J����T������S��R�g#UH���^�Nh��埽aB�o�?!^Y�����7��؂����}���X^I��!5\F�Y�6���{ITR�ⴸM&Tt�A�fE��:�8ߊ���B�G��Lbc係V.��|ϸ��3�_����q����l�w� ���Q����1f������M��ǆ���:D�A(dٰ����<�2�����sk��C���˘��3����s0���
�	�����A�������0}���-xR���!��c��\`h�W«p�@kp�q�m�~,[3\C�ٔ�	Sx����?��P��F�%�z$��Il��1N�qa`�!D�:p��j�S"��t��c�ʜ%&S��T�^њ������b������季�d������B��&�5��H����Z��ʉ��R�d�oƦ�<��F�z���[�D�gF����?�P�>|��/�|OW�8V����l���zrX8u�ث�<�;{�"	�f�L/.j�D�cz��|�3=��|[x�����?'��?x�����\����0L��%ILe�pS���	�����Y�]��0x����'��mY�f>����A����m�I����G�����7��+WD�7�ܿ�\fݣ�j� ���I���~���nV�/Qȡ9�?R�ĥw4�	�˃�Ь��������z�t���#��k���u�e���5����2O�m������Q����=Ys+�wb,��O�hF�<��HER��ڴ�`�[��7���~G��w�2�Wd(�#�׸k���3�nO[����	���'����$���o���叆K<j��Xƒ���e��0�B\	��ꅓf�lB*�K�ɣ�x$�RNLlK�u|� �m1ד�%�8�r��r �%�2��.%ry�!�̗���$���T�$���N%��*R�B���fQMR�|&WYo���lG���Q�A�I���t&�>ږv������I��I��	.le�$�xL�z�Gq��Ů̆�]��,%wJ���@'^�P�oo��`���P����ϒTY�v��f�tܲ���k�I���Z :R���Ch�%�C�
�sɸ�ۦ�j�~>�hm\�}3��,����M��Ǆa���p!�����荞ŏ�
�;Z�z�L�(��
B!r��� ��^�v�n5S�VY���
6�S����� b��L�Y����|�w�z<�����������
�����\`���ͥp��?��P�G�`!�����M�?HA�{h����Ia�]�k�@�Ӊ\Ƴ���S��oy�y��^���@�Q��:p= B����<V�{.�aZ��K'����/,��|����8�`+@Ͻƻ��
]yR*E�A�ٓ�קߠ<��4�ꘄ������K!&������X����_�OV�-UM��pA�O���]5�N8��1xM���9<i�������
�bq~���ܖ�����zxC3�<0f��V�3���"@`_�z����n���@~�b�8?'��(��{,x�ř|���df��/７R�>����?��?�2��ʰoÕ/�\�LzGd�)c]#�IƼ�2�x/$X���%ƽ�sݻ5W�Vx��xU�~w�6�ʃnS���p�������ƣ���w0s�{�n�2f��(��������J�4eL����2��1�[�s�w�$xw���4��g(�6��xx��-�м�����4���ױ�L�����k�hG���X��^n���u�*�YB�Z�br-
ea���+lTP!�1Q�&TWW9rB-��rњRS����UT����M(��~/hڮV�rw<�ҙHJ�Jf#�+	=4��Lr�8��t]�db=S�����������[��4�ŭD�~�89��Ŕx��d�N��H�S��bZ���9�*YT���H�Dv��m8��A[i��~E��&�$.q���p��t�=4���c�u�z.d����-V���l��az�U�g�v3׮V.q�3�p�7:�Y�\d�Ǚ����Ud����~Xv�9C�8_%�݄�_��J���H^�2R�J��Y��n��7���ΆH�6�[�ߋ����Qm�,�˵���Φ�:�J$ҬU=I�vPζ����=�SM���U7�qґ:���Ɩy�9?f�bq?��Ģ�*�E)�ʕ�'��iU�ӵN�uysk��:��������Ccs7���Ė��:�u�������ƞ���Xу|�<���;�n�9�e�b'UG���¡!7#	�o}��Mdq;����lV4�ɤ��;��Y�C⤎��t�ɬ(v�:��C�s�H;S�����9��,,z��5W]9oo�^�M;���\���'��4;ɺW�C�[Bc1Uꈝ���W��-s��h�ӌ�j��j%��J�l�|R[I�k��rZ�&�I�Cc�T,XL��*���s�zv��v��ȧF�}�N�3�H�� l �RcX�����o9����H8��mӨok���k��D��˰��0}]�A� #< �����i���M��=�����C�E��������&*�����?�:q���E�>ؒ�I�#*�Io�uI��O�{�.gc��7���H3���b��l?߃��k�;{��G�mַ[+����cUf�����kr��J�QsIQ,�c�+g�(q���DR	5�XrD3R��G+�JF}]ϔ�T-)����s�ݶ�J�2��JeC=ᷳ�W�Ŗ�Q}�f�b���|�lt����<����V�������ύ�����@p��Ilg����7�����df6��׃�0e��j?������a�l�2&���������� ��O�w��g���g������?�?���7?eW�«5��c�U�2��*��e!�pB�gclT��J��)LU`�U~EXYY�`��_�C�7��-�y�/�����_�b�/?}����f],��!�7��B��KϨ����c��fK_.���qޮs�ra���%?��)*i�i�Z���gKK�e�Hp��?}��W�fy��'��@I���8K_,��g�.Q��_<Dq?޳5��ҟ,=B���p\	��q~�7~�����V��������?����o������7t�����y�s��"�->o��3���������A�磋�_����k`�[�(ǿ���t���H_}��4yf����MR<�^4��*�����rL²TڕJ�+'�,�%��KpR�O���3|P|�L���
	cf$�6)�^X5�1�h	R�Y�-��2<���򓑾��l^�r�\����(��5A�)
��j���2W����Z�Uk����@��#�������ꀐ��~0p�U��]�5{�cO,$eC;'����$�q�:{�ɤ�3=�(����L�遅n"E5��p%Q��E���*REQ*J:�!�����࣓��	Āa�	�� 9�=r��CJ�*UI�tWw�<�W@u����������q���F|x�o��U��d��9yK^D�JE���na�B\/β�Pf��J��ql���rҰa٫���s1[QV�ʪeģ����υ�ɿrQX�Pe-��`��[�r��Sp��T�9��
��#�w�wb�w��r��̣�r���\ɝ�yn<A?��Q^\ �G]w�<6�����?��?l�;`82@�w&�B�6'��eNV����V�I��m½�MQ=�3lgW��g��8Ν��[���^{�D��o裍��ﻺ*��7F.�1r�#�������v�+���>����$�vp�h�rɳn�{I�9!��t�,V�*sqg���=�tf���S�Z���������-�#�s��ڮ����'I?��^Ϗ�r�5^t�[h�p��u����0���ĳ?���5N�#yuv´�5�$�8��)�����,t��HW�Ǐ nL5S���������ViT%^���ѱ��x������++��.3�BR��>��j,�������C�n����(sa9"sC�<���$�ى?�p��3��n/�f�X���^|�l�tԞ,��g��N �f7��rn�����կ�/�5�f�86�O�r���g����6���U�����[�8��S�ۂ���.�����ON������t?����V���{\��#X>�����>�w+�wx�Տ�����+�{�_�����;�����_>�A��=��&���:�:��:0~��7_:|�����
_K�mJ�5��1���mXf:jb�,n�v;k�3m+�AaS�uE��504��z����A6q=u�z�.�������o����w~��������~�{�H�P�YI������k���0���S����(ڿ����;�1��x��w�>���[o�~�V���:=��W.���`��i�S�%�6��r�zθ�f�]�8I�\�nFÖ��.�};�����2��Q�n��s����&�;�{d}y�P5>�R`����5��r
�\2�
��f�9;i5;�I�-�tZ�<����1*�bD�8�b$xu��|�->�N>�HR�o��$�7�o�3Q�˒SH�HReC3��\._���R6�7d�9��<)�gB�ՠ���Ó3$c�}/�����㐐4#�Z	k��2��R�j ��E�/�L�M�zd+��\gY�)GJ�&�qF���)�H�ڂI(�&XJ!�$�X���:�KѴ[np{�T� �t�nͫ�iO7�y����^ q��KLw*E���˒#����֭���)DT���()WF��"1^�'X�H���e>h�#R�@U��îٱ�g�>e
�P�#�O7�6�M�ӗ�XU���*�_��(>�v6V;g%�$��EE�S{Fw!��^"�ݨ��B���g�1�*��D@��ΔD��kH_����[�ܡ�!$�MB�jN���1��[�W��iX���0��ZW�3���#�इ�;2�W��Vzy iO���@דȋ�%BA�"�L���*Eil>/�'�K�(@
�0cNn��Uj1Hf15�j����.��H�c�4	9����"9��`~�Ns�&���(N�֐����l��|��s�6�X"Y�P��aN�S+3?2l�_�<A�����d�D<�1l<ک���HX�9%DN׏fy'���x`�x�ϲH�k����X�#mfEcP`UjB��6<�����ڠ��F��@ms�s|�5��@_�LXH�'�a��sۨ� /.��<��6������0ʐޜ�>���U�����B��+��:$����nֱ�0D�T	�F|�s�p�/�ԨaW�X�L{H��e��ާW�뛔� 7��nZ�ܴ��ip�*�E<�Mkx���� 7��nZ�\�~��B��,H$�J��W[��A�[ٿ��Ń�R�R�������_K6�W���������/Ō_\;��چz�!���xO�z79�)O���{�?z��[������R_����{��6ޥ�9㽊���ұ��r#��K|ډ�^����t׌w�:���54)�kJ�� ��yiW��8�ꭖ�3�Zv�X4*C�5)�HG�������L�R�.�4g��J�W3Vm��P����^���ek=������R˃��6��S;��9}�x/��;K����"K��5<t����]��-Dn���H���pP�8E��H��4��7X3/�uu�2��Z�0��������U,�9�i�/Y5�NfD��qK�NT��T�LwT�ΞJł�Qwڄ�N�H�)�M���//�[���ڑP�������0&���Ƒ�ͫ��D�|=h��)Al���j/�?O+ua�I��� )�!
��)�Z��=F���hf��ld.V�Td��q�jf���b;�
���x8D��vL��T�.���iUzSɯ��/U� �X�U>C�2���S%�)<7�<��E�B�"[T�!�E/���u��j~�5f��S�|>up�,�O<���N.�طH�y:�� �4o �?~��Rk�A�o������o_	1���3�S�]���8j�4���e�r&�P�-�Y+�<C�Ǌ�FέGI�Xg�v�h|�*��
�M�QxXYG`����G[��/��b����PH%�z�
���)�%�[��������pB ]�k�b�A܀��XD��3���&�E#����)��L�6�tOEG���j���ѹ�u���#ݨ5'��8 �X����lk�tq{����&�d<��FQb��K�]��� �����Μ.���a������mi�����	t�"¶<A��ӑL����9/a��$;d+;���B�Lw!
A�h���"k=��: 	r�W�!.��N��A� ��
�A�D�"7ъnE/� s;��G��K�ue��H���^/�{k2E�x=t[�RH�&O`k���!Ǳ�zF�I�l�|?X��ݧ�u��f@D��ҙ���@O�<���ti.���o�|��z��%c�����X!�6�*J�O7��vwr S��c="�`!":�5�e#n�b��N6�&"�o:�,)��P�kM�WzZ+�z��N����歚=���jfź+�JX�F#�o�U��a?��*�yÓ�k�
�~�c���~�c�ϱ��xa�9�Ѫ�C�>Z��V�w�����=�ڕ\H�Ũ�A�jtZ�V����L#��	�?�q����;�G�3����k#*pj�HX�T[��P8�y0��T����e���7�É`W*3R�\�ӀY+[�^ÂR�1`�n,A��2$��u��Q�D��1\.�1�2���:�
�HJzd,���Z�
4O��k�`:��y�ګUp�.s�ѸOhźWm��
��Au�C4�!�E���o�.ͥ�c����r� ��[*�F���������.����á6�Q+F�l`� Ֆ��"ǂ:�Cj$Ҿyy\��P&ze� ����R�kQ�7R��G��O:�^�$�$z�sN"����*�)Y�x�.�����c��_�%9�� ���lh��L���=��D�U�=6:�;�Ro�^; ������~����˼��Q�M�S?��9�g��J�{�t��9W��s<>&^�9�w�W#��|�����k.K�/���P����;pȞ��L�~*��|�N����f����y<����x�~�N�	������9���
S��:��V͗i=���������ϋJO��e�l�Z�x��������p�7�f��������m�3������������݉��������z��Y���﹧�t����#��o���#t��,���۠���j�w��_x����w��0����=�������x{a7���=���1d3�����6����bG�����z�>�t[�I�g8�������?�
��(܍"�}���Ga�+��Н���-������ڱ�g����Ni�����ߝ���>�cWtG�������!�����о���Q�� >c� v������o��`Y|o�����K^]�� �����m��	��V����6����v�}�9�]��3����{��6�*�����ʟ���r0,U�#�4�7�-���3�������
:����B9���.��i�m��<	�rr7��P�u�\���C�
<�yC�"ʴ��71�����Lj��<�$�*\�q#������g�� �ڣ<Iw�L{�8������P���>(d�0���u�G�tc�zA)��u�Hl�����p�e���q��t��&�E�&V�q]o<vĢ4���h#��5�I�V_굠99q��j�t��P�t�xYw�]��gOw���7�?,����۠�]k����w�wD{��Ŷ����pf����
�[���	��aE1�����-K�s��B�n�팁��v�鸞��t,��f6������6��Gqx��G���mК�_��j����Y����
��I]��LqP�Nb��Ǎ^m.E~wP�� #�qE�Ѭ���FoV�tD�D&/{�Ak6���և��
�)�Cf3��h ���άIQ-�����~7�e�Q�ɗF'�׷�poݫ���䜨�_DՃIe�R��k�}ֱ�Gyh�)Aݶ�mF�l����ܳBߝ7��>�g��VWwh�?-�ӛB��c��域�0��o��I�_���?��H�_`������7B#����Ҕ������������0���0��P��Y��t���tŜ �Y�1��<�'I�S��SQD����D�q����E4As��������S������/,�a�ֽV�hRl��q�s�H4�̯b{�G�k+޺����Þ��(���ba��ڽ2�z�[74�bA�tU�B2�C�MYgnO=i�s!���� ���U�w-��r�"��/8<�)���C��W#���o� �����3���i,����WT4���+��������_�����Fh\�!�+�����f9��5�C�7�C�7��_���k�f�?��������A��W�a�����'�\W`�Q���'_���n�o�%~�۟���[�Yo��٦,~t�u��k��0}-�1m}w۵9]գB�?L[O�}����Z����?�51�������w6���;I����r�ӲB\.�ñ���#ų��ڗjx�e�������(lW�ܬڧ5�]8Zw��5o����)�BqM�����r�_��r����ɱ��Z�k�N�MٳI�ڶb�u'�l6j�ʇ鑅�J$���\���W�Io��W�"Y�ڇnubfeǈ�e0�]a��H\V�c�(������d����f�f<�����9�L*/������+ ����B��j?��P����w����������?��A��H�GC�'p������7��i����=�΀vZ��ڝwg��'cGܮ=Z%m��ns���V��i�r����^R���`�]l�2J��n���������l�M�
ֆnj�$'�4y˓��z����������+�|pal���T�on�h'��(�ɓ��MYm�12���w����{%sQ�r0��R�܍5�j?�|��$yّ���{o�P�Q<�?���������y���翢�i�� ������:`��`�����y��a���������^�����ρ�o��&_�2��MД�������x,�����S̳���M�X�!1�������}1��#���2�����G��8X�kX���?X���?��������}�X�?���D���#��������������_P�!��`c0b����������}���?��O��C�W#|���?5���Ƭ��:����͡��~�(�7���/��������|/���+��_��]�8�:�e�I{�8�����fg�b;z�1��χ^���ښ*�O����t�Z]T�Y��3e;�dEX(������www��������7���r!�f�҉O�g+�c�}�<ܼ��?�S9e)i�6�����mwX�B�/�b?��s��2���P�#�/�q��p!-"]�V�Y�ع8�m��K�~08,.r�ұ��봥Odv�Yӎ1�%�(������2а����?sP�5��o�]���G���]���̫�o������gl��D�(�L�?� ���D��<���dEFh�Y6�E�fY��$J��[�����A������|��'v߻;�Z���뽻�T��Ҭ�d=z�5_�c�+�G��v��&�$�X;u1#�����z26�[ud��:��*ê����l����T��-��cB^,�}Y8��7ݐso� -"A[o�BO��09'N�0��6���ƚ]�̟��M���1��?���������؁���:����@b���Ā���#���@>��?(�a����������� ��?�� ���������@&����߷������?�@������Ā�������F�__ }�7��r���s����[��(��g�o�=��`B�g\h��\�������ᛉ��8?|3����5��Er֭���&�fѿ��|Mg�������?^3�Յ����ǎB8���Դ�Z����Z]��)g�o�����k=������	{;XěQ�У�i�u��?VUe��t��W��3H.Íǆ>UǺ{
i�hvW�V�=�SW�#[tX�9Q������wW�h�k=������-k:�3������[7P�u���wo���V���l��:����j�9��hi�r���?�MN��=W䇳�珮�æ,���Q��v�w\1���״�=��)˵Q�*q�.�ұ��N���y�W�=�9�zRt,�ν@�v������3���n����D|�*�v-׶ܟ������)�tr�.!�
������rQ�k)��%Iv�*7%\ۚ�d�<`��� oҥ�+'K
1�o����H�}�]l�w�E���@\�A�b��������t��I�)/PI��qL�Q�d/�\$R�$<K�L��$�dF�9+R4�'yS)�I���s������_���Ö�M��=����a7���f�iD��LO�q�-��)���Ԡ�-�.��;k�J�Oʨ�ܪ3�%8v�yI?�}������C��J��C9ei�]G��MW����ۻ�NQ������-~��E<�D�ǐ4�M�C�G�Z����Fx����%���+M������ ��8�?���)��M��Eq ����C�2�?�!����sO�?�G�����G��X!�a �9�����eX�k�����y�����te����H���3��t��ן��mo�;�Ĺw:��|��v�]˝�j��gsH��,W-m/g�VӶ�:�y�����ˮ���2�I͍��v�f�����W���6���Cm�2��~(�u�P=�.I �L����_��<�8�0ew���G�ƚ��n˒�Wj.r֍R���&j�7ʂl���;7��s����Fj��`�	;
��2p�=��}���!���?��B���]�a�����L�l?"p�����|��۷����7�.�i}V��a���%����'���"���� ^_��_�.�
I��T���{5�J�g3/V7�8�
r�J�2��]Ycz1͝Ӳ��2����Z�p~"��t`L����]:M�)��s'|���pM��O�5��
j*���6���K^�)~���ɪ��K�v��ȱk"��|5�m��L7B�^Z�_��U��iޟg�<_���v��JM��e�b��Iz�
\�ܴ���.�,�?��B�����}�X�?�!�}���?����_ ������G�wj|���ǰ�b���2�#V�T�r����?���?7���['�|���'���s���Ҫ�3��ڗn2a��.�/�C>ݚ�1^0���ǗǄKenS�j7�x���u�s4�~=�,VK�&e�4���)�B���������_�8��7���r!�f�҉�w��������yV�<s���4#��M֛�g*aM�EW���ɩ����N<����vdr.����[�;�:�ȵ����6[f����ѐ^�˙QΦ��^��"��s"�2�9ٚ�չ�R�r�V�\r�nQjIW�+;�귱����!q��_�����?��Ё���T"Py�Hɱ�@%b*�RΐtD��Dfd&2YL
R|��#���GI� ���s����8��~e�W�^n��.£8,;b���Ki0�8;؍�I��������N��La���{���F��^�N�$w�\��T�:��>Ɓ5��$�H�\�֋�up�KS�Y����1�̒������?������n����$s�/M����$��	��Ax�
����U]liJ�t�����5���7���7��A��f�˳)Ǒy&Ź�	�(	|�朔R���Ibα	ɉ	ñ<C		�pyL�i��4������?�?��+����)�XI�]߈���әl˕G�z|���ao�_����Fթ�o���jm�xLӾ��\���Iƺ�ܣs����w.Cv�f���ˬ��tx���Ί�]o5ڻ���^px�S�s�����Fx{��T%, `K��g��,���X�?���hF�!�W@�A�Q�?M�����и�C�7V4��?������� �ߐ��ߐ������_�����b�q�����p�8���?�~�������f9��M ��0���0��v��Q�L�1߸��}�8�?������: x��}�?��������]���_Q����S�����'�&�����#��4�b���o������?<P���\�)�Y���&@���11�������}q��������� 
���]��`��`���`���`���?�������B�Y��@&����߷������?����A����}�X�?���l�r��������A�w#@�7�C�7����/���q��ʮ�qw���#�����p��z1���p�.�D&M�8�3���\��,�b��8�L���X&a�$�D$.��d3!X���Vo�����gx�Y���M�����}��v�eh�g���书|m�Y��:z�,k.%W��]K��얝�+����q�8�7Q�(� L��.�"����[���J��*9	p�z� OI��r�ֻ�^;�}y�lGGC㓺�ƞ0M�G@5MM7R���qm�ϲ�I;������le��>�T�36;�H+e�z�'�5��g4c�U_%�c��-s�):�����J�ڸ�'���3����?�C[����W��}����z�� ��3t�� ��c ���9��������?]��?`��;��0������ ����?:��[����A�Gg�	���������?������?���@��������������z���/ � }��I��?�������|�����u-���K��lG�A�Y ���?� �������+{���Qs�,���i �|C��]0��+#/$	r�V�]J}4��қaʌw9�v61��vw��6m�Z��*v����ׯh�5�Q��)����)	׶�a��$U[]�y��̥����`dA.i�)��'-Ղ���k-�N�����a��߿��z��@�Gg�X���������}�������A4��!�3���T��qL1X8z$�1��p��!:�<���؏�0&�� ��������w� ��W������ݳL�ny����gŊ�l�U�����;y�:9h�i�ꉇ	T��c�M<��P2�ݡ�����r�&C�����棃Q�~�X�1���TM}ךǳ�p�?ދ��_���=|����Ch���������_��(��V�������'1��m��#�{��ZA����"Pᐎ�'�hH�8���!�����1J0AD2C	#���ak�����+���Z����L^V�x�gGY�s*]f6�|ԛ�"�Z�c7�~L�6_�;<%gv��1����r6[��2�Ғ_Bs1Bu���j=��L6#ɃB]O���O��Y����I�-~Q���t��ދ>��Q�n�����6��s�m����E�����o+x��Kn�_����	7�K��MydpT�S'&Q������	��e��Ǿk�2�FL^�Ħ�g���=_�sz���J���/�շ&���>��-Un�eM�~R�^��K�ϝu�k���q��ꦟ�_P�7�^h�3/�Z�ʳ��H�sc؆�&��:���,{}��������y�fq��8vٰ�������	q��	U�|K�
�k:�d���T�y��S�6U�ٰ���!* ��	����Jr�3�iB�R��p�
��,Lg�ʕ���(��6�l�Ҩ�d�#�n<ەXs�HGg�j�"�E�]�AR�^�?���j���M ����B�S�?�hm|�A�o����濻C������m������ �������'�������{t���	����>��?��g����Fb�������~w���<� �*�<�<!��aZ���Ys�
?.'YV�Q�5-�1\1� 
�Jd��9YN��NDs�"�y�+_f��ɸ�A�Ϩ����������1>��6cY�6x�"�F�U^f'��&]~��|�,g��Fa�"�z�8�e6���F6�h7{&|y��MH����O�<��"�S^�5�9��u�LeK���A�����j��,5WaDR�{���.�tM!+6f�Da?��=w��"��;o��}������
ڸ���������������w�6��8$�7�>����[���#��� �������������냃����PY楍�i�����s�.�ϴݫ�n�E�h��<��.�o�.c�F�s���+��rm뼸e��Ȼ����|�c#�/$�� ��YD���Ư����R��J��a�\��5���M�V�q��֦8Z�hi���|feܗ6�/�6�un��gu�%��@f爣�~9�j�sX���	�dz̎�4X�/�Q9����o��쇡��8��%?a�� ���p�b>��#��y�_�+W�F�����V$��,�7������� 6������|aoƦ�b�@ь.��4�B�!�����?��:G�߃�4���ު���w��;yoX�I�q�[��N����=��.����=��.z�VR'��=��h�o��&si/���I�c�xg����Y�V�5���3F��6;�5c/�V�aʹj^Ųj���3�6�?��1�w.���r����eƄ�L+J& oJcB�����	+p���=0��;��d����)7��ɋ�L9c���jaٴ`D~���)�t�����U�41�CaQH1抒S�8F��e����kQ��p��?����/�����������O+hS���o����P�(�m��o����뿣��{�(WŒ������l�n���*+cl�̘O�ol�F((�r���؇���b��y`�c�d�0,�m����E�Z�ڨ\�E���NV<*��LTG��b��su`����S	��@f����YW��Pwu��?��o��\���*Lcq>��|0_%�H�8.�f��%w�uBw��fF��=>��D����PȞg	ѐ$��|�H2s�������7���`���n]�?����>��O4�[��O ����?�B������i�v�>�?0���������?�S�b�`�t%#�Q�28�t9Ә���[����W��Ƣ���S(X"����[��y�x᎒䥻?��֗�܏�7�U�6����<�dUU)�b��f~w�����\�/�?����	7�ˈ�������b��F�ҸX��U�,�<�q�ī%Y�������A�I)�.��k5v<è��>�g�����}�W���t�6��U���Ǟ�?|l��������.��
P����?��@��@��S��h�+	�_����cu��]?K��6������;���w����o�����pG�	 ����1��?��������� ����������z���(�!������]���Z������������M�v����l��������_+�������l��������_@�����Lp? �����������������1p�"z����������7��^����{t���	����~�����~�_4�9ӌq�����{�:'��^�,���t�TgT�iq��Bd�y*P���dY]TG5ִL8X�p�T(�+��/�d9��;�]x���Ů4|��2'��F��.^����y���5N��5NlƲ*_}�7�U^f'��&]~��|�,g��Fa�"�z�8�e6���F6�h7�_s����1� ���t�q�`l�dS�ҵ�l|�<��|��Z�)K�U���ީ'��,]FSȊ�1�DX��n�t�?����ȃ�W0��
��yt�����-��������?���?����?���aB��*�p������OEȠC�B�Џ��h�F^�!DD���Ã���ԏ�@���{�'��o���ܘXW��I�/�__�(���mNB�v6�뉜´�/��m�C���!"Ȝ�.�4�\0�f��V�6��;L;�PQk�ip�\�,���1�J'�)J6�,��B��+���o��0�Rw�?i���Q��Tn�����{R]��=C��(y�����%�i��|(��m�����P��6����{����5�����@T� �������?A��t�� �s ���9�w��`��%��Ah7h������V �?A�'������>8���VЩ�!P������z����������z���?a(��m �?��'��򟺭�?���[A���@u��?����w��@�SK�	�?x���^��+���ެ�_n�����.	.e��g�^l,��t�����Q����H_����l�M�������0ʯ��~yVyA��V=aE\ݞp��A6W�S���1%��&2����6F�ʚ0Gs6��PmK�t%!�}��E�旎��3�7m�N�RKU�m��ٲ�o��cu�M��֕ �j�S]W_J������\b��z���4��WG.�������j��->���#������#l5��p)��8��%�S��Y���^��'6e�̼�gPL@F�w�4ۚcb�	V�!q����U�| ��#�B�!4�����?�9�������������o+��G�Gġ�1�h8�H��bt�T�$�S��7]2����0P�b�I�!P��>�����������ߙ��C�<��`�ʊ8B�s�w�ω=UY����T�6g>�?-��?�7�2�T��"�I����{?�Cٞ���l9���q|���`��8��4�Mj'����z��[O]���3���^�����ԣ�G���?����Gi��?���_;���~��}�ZC�?>����T�>�顪?E�Cq��O�C��?y�ͧ+�o�]X�UQ�����g�u$�jgf3{�fgw�;���j���e��l��j���#BC�_���v�n۫��	���HK 	R>!+��X)� >"H,	D(��_|D$���B�}���k��f����J��U���O�S��S��$*�*�ب����p����5��P�� ]���p+�j��'�p��^�LB��P�x��D�7^ى}l'v�F���*�,��V���J� ��jW��K��6�#��ܙ�{1��wZv��nk�{JH���3O�t�ԇ��H�Fnl!!!��JX�k,��ǂ��ĆcǱ3�SFa�}:�r����ӧ�;Ų��{�H��=��1I���=e=�����׀�v��/���
�{����a���QG���%l���]ۡ*<s��0��R�"J�P-�wC�W;G0�$�R�rUB�ߍ�#5�9�N��{�N u�Z�g�;1Oׇ�;G������6�vc'L"?�N���m5֟��={�%���h_��MCz]�9�a������Pv�2������m�d�N�лs��['ǻ5�,�ة��DF��I�I4.����|��=���2�o�߾�������~h�Ҋ%^|	�u�EU=�P3zI*z[�P$�`I��F�L5��j��%T\O��c8������E����4?�������g��/��Ͽ��q��yp�P�}\&<�g����]O�b��2=�w/n�CUA�K�p��}�g!\�q����s�o�;\�t�ܡz=ag\\H�]��ٺ �����ü��C+�}�Y�J�yi�����Kxq���4�Vd����߿|�?���[�_�nu��#^�ο
]�|��h<��.�A��7S�;����/���c�$����Oaɍ��' v�c�^��O_��O��~�O%��߿�����w>�g���؟ij_���I�xS3���sWυc�߿��G�?
�r,�ŗ0,�6�p�P�vRC3iL�%m()EO������xI����&3�n�i<��$kX;�����/���V��s���q�����?�t����c�;"�G���Mp�@X|���n� E�z�Ƶ�ʵ�O?.D���<��s��>w�����Q������	)$虣��i}l��m����*����9�h����\f֚3�#��k8����;j�ՠLf�X8[B�Q��HVi6 �����c��,����Erl��J�5Q����:G֖�<����Ӛ5먭4�v{δ8R]�p���N@��Ưp�)W'#��q~�o�d��<����橾,�4����,of?/�Kʌ�s�Č���N��3$e�}{�u1�C|B@��W}����~`+"霰q��l��s$���i��5�l���o�'E��<��]Vh�,�������l0��� H�e�5�Wp͘,c�R{7���R��������\ h2KX1�KM���� �ij�RAXъϋ$�)%���v���@�ԢMv�b��IT(��w���&�9��K��; K�=�y���C��lGRųK�
��]�1s��|�APPsrO�.x�X�0gG���6,xX4�ل��{����N Zuy&F\E���آA�qJU�<oyb!H���(U2B��Q�vK�Kn|�`4��&kdR��Is�v�����q/��LV�"�\�e\�l�&�7��GR8�1E��W\�d��fk�q���V5^s�$(ӣ���NJ/�9�?~�ɑ
q���i�����*��n<;KN3�A��a�'[ŶV�U�e�U,�Wp�G#��P�xUw�zj>Q�_&m�].�)���5�i,���ƃ"-�}fa��e�)"®4�e�l�Y��u�|�F�]5���	�F@%����S�;S���Qu:}����NB�,�J-of�~�}4f!j=N�=6�1��X�㰚LN�z�Y� �=�Y��Ac�i���Yʟ�Ω+nF�q<���bJ}�C�f�͍���^rJar�VrV����ԍ
�ʝ�jxa>�Yv^{��f�h�Zn__�
r�Od�X�-��4љ1CE�9��(�HρG�E8�8ңİ�S���Nb��z��K�Z�a��?�&��:=-�d[�c��e����A[�� hy�>Iy�g+:�+7(��S3$YGj�V�ƝRäyé;�-I^�U�e��Z��L9���=jXds-dR����X�j7�6>����+�X@�T�
��F%���D���X����Z.�hV#�����e��5p�i�2��%T�FE 񵪗�O��QOc����N|AWm\8��5������B>��]������Rt'q���%����5h����zb�r�xݛ�J����M��Cď������V�_��!�+e�ߞ9X�����_YN�_�}�
�GW2>y��G&�d2_;�LH�>tI�Ȧ�b�^L�g��C��Mޭ�Lޏ!�A��nSl�	��{����v�%��~5=u;1��=f�UޯU��hc+��"�sŔT�6�1���"+�g�\�!��^L�ɜ(KU�����F]���|�e�"QIۜ٩ᗓ����{>��3�~Ն;p��漉��ۗ�#K���`�Aw(v���;��Y0u�0�f�niX�Ѳ!�C���wS��6�6�h���k�Y�������^�$"]�3ŔU���v\��cHP{j��Ul�4W%S�My<BRf�iL�ٚ�jɱܜp%`t��1"=�Z�ӒP���y����J�Ffni|��{�Tz)��T�|���~�q���'a��4~Vof� k�r�kL�F:lf=u��%]N�����R�_���_�;h�</��g����9L��3@.��ܛ򮤉��UȼPd�<`Sd5UnXm�(��wM�"��b�w�b�T�v<G-�����:U�g�3�y����~[�\��ڍ*_��?݅~t���H1�׭�o�\j�7nBq���C��x��9}bs�����%_��D��3o=�^���x J�<t[�bDF�G4���� ��h����F6\���t0�dW�*�t�G
���v��<5����9����5�>���0;h����1^��Fv06�e��\N�£�M(Y�'0eT6�#��x�ק<'���!����i�g7�Q��I�8�zBw��0�r��JY�(�Y�6厫�y�j8ᬮ��%B���Ͳ_l�.�(2�gP�V�xE�&�t�m>�i6~�����sl�?�O��cc�z������'�Z��n��g�~�C����^�t~��TSf���x���9h{������eo�о��셐�	��eV�_ ޳h�?Z�bG"�������J#�;��g�]�.�'}��n��^"�����=]�W���|����Z5O/pD�����3�S�C��l�;;�v$xg�>׎D������h�΋�Y2
ܕ���-C�O�oE��j��;�c=��:}�l��;~�6�ȢnZ){��p�.b�C�m�(�gW�8���?��u��}�h\?m��c'��"�xb���l`��6��l`��O2�?�� � 