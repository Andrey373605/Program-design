    ORG $8200       ; ������������� ��������� ����� ���������

    LDAA #$AA       ; ��������� � ������� A �������� $AA
    LDAB #$55       ; ��������� � ������� B �������� $55

    PSHB            ; ��������� �������� �������� B � ����
    PSHA            ; ��������� �������� �������� A � ����

    PULX            ; ��������� �������� �� ����� � ������� X

    SWI             ; ����������� ���������� ��� ���������� ���������
