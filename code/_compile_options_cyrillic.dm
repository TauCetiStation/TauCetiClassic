//edit this file ONLY in win-1251!

//more work on TODO:CYRILLIC

//ja problem
#define JA_CHARACTER        "�"
#define JA_UPPERCHARACTER   "�"
#define JA_PLACEHOLDER      "�"
#define JA_PLACEHOLDER_CODE 182
#define JA_ENTITY           "&#1103;"
#define JA_ENTITY_ASCII     "&#255;"  //for old text and histoty, we don't need this anymore because goonchat (God bless goonchat)
                                      //todo: clean saves/bd from this

//thats not compile options, but it's good safe place for things like this
#define CYRILLIC_BRAINDAMAGE_1 \
	list("������!", "� �� �������!", "��� ������!", "[pick("", "������ �������")] [pick("������", "������", "������", "������")] [pick("������", "������", "�������")] �������� ���� ������;�!!!", "�� ����� ���� ��� [pick("���������","�����","����������")]?", "���� ����� ������!", "�������� ���������!", "���� ����� ���������!", "������ ��������� ����!!!!", "�����!")
#define CYRILLIC_BRAINDAMAGE_2 \
	list("��� ���[JA_PLACEHOLDER]�� ����?","������ �����!", "�������", "�����[JA_PLACEHOLDER]��� �����!", "�����!", "����������!!!", "���� ��������!", "�����������!", "��������!", "��������!!!!", "����� ��������!", "�����", "���� ������", "���� �� ����!")
#define CYRILLIC_AHELPCLICKNAME \
	"������� �� ��[JA_PLACEHOLDER] �������������� ��[JA_PLACEHOLDER] ������."
#define CYRILLIC_TRAIT_TOURETTE \
	list("�����", "����", "����", "������-��", "������", "����", "���� ����","� �� ��� ����","����")
