#include <amxmodx>
#include <amxmisc>
#include <sqlx>
#include <kzru_gamequests>

#pragma semicolon 1

#define kzru_plname "<kreedzru> Game Quests"
#define kzru_authors "kreedzru.xyz"
#define kzru_version "pre-release"

// Создаем глобальные переменные:
new kzru_GameQuests;                 // Общее количество загруженных квестов
new Array:kzru_QuestNames;            // Массив имен квестов
new Array:kzru_QuestTypes;            // Массив типов квестов
new Array:kzru_QuestParams;           // Массив параметров квестов
new Trie:kzru_QuestSettings;          // Хранение настроек квестов
new kzru_PlayerQuests[MAX_PLAYERS+1]; // Активные квесты игроков

public plugin_init() {
    register_plugin(kzru_plname, kzru_authors, kzru_version);
    register_concmd("kzru_reload", "KreedzReloadConfig", ADMIN_CFG, "Reload Configurations Quests");
    register_clcmd("say /quests", "KreedzShowQuests");

    kzru_QuestNames = ArrayCreate(32);
    kzru_QuestTypes = ArrayCreate(32);
    kzru_QuestParams = ArrayCreate(64);
    kzru_QuestSettings = TrieCreate();

    LoadKreedzQuestsConfig();
    //SQL_Init();
}

public LoadKreedzQuestsConfig() {
    new KZConfigPath[256];
    get_configsdir(KZConfigPath, charsmax(KZConfigPath));
    format(KZConfigPath, charsmax(KZConfigPath), "%s/kreedzru_quests.cfg", KZConfigPath);

    new iKreedzFile = fopen(KZConfigPath, "rt");
    if (!iKreedzFile) {
        log_amx("<Kreedz Quests> Не удалось открыть файл конфигруации квестов");
        return;
    }

    new iKreedzLine[256], iKreedzSection[32], iKreedzRightPart[128]; // Объявлена переменная iKreedzRightPart
    new KreedzCurrentQuest[32];
    new iKreedzKey[32], iKreedzValue[128]; // Объявлены переменные для ключа и значения
    while (!feof(iKreedzFile)) {
        fgets(iKreedzFile, iKreedzLine, charsmax(iKreedzLine));
        trim(iKreedzLine);

        // Обработка секций вида [Quest_*]
        if (iKreedzLine[0] == '[') 
        {
            strtok(
                iKreedzLine,         // Исходная строка
                iKreedzSection,      // Левая часть (до ']')
                charsmax(iKreedzSection), 
                iKreedzRightPart,    // Правая часть (после ']')
                charsmax(iKreedzRightPart),
                ']',                 // Разделитель
                1                    // Обрезать пробелы
            );
            
            replace(iKreedzSection, charsmax(iKreedzSection), "[", "");
            
            copy(KreedzCurrentQuest, charsmax(KreedzCurrentQuest), iKreedzSection);
            ArrayPushString(kzru_QuestNames, KreedzCurrentQuest);
            kzru_GameQuests++;
        }
        else if (parse(iKreedzLine, iKreedzKey, charsmax(iKreedzKey), iKreedzValue, charsmax(iKreedzValue))) 
        {
            new settingKey[64];
            format(settingKey, charsmax(settingKey), "%s_%s", KreedzCurrentQuest, iKreedzKey);
            TrieSetString(kzru_QuestSettings, settingKey, iKreedzValue);
        }
    }
    fclose(iKreedzFile);
    
    log_amx("Загружено %d квестов.", kzru_GameQuests);
}

public KreedzReloadConfig(id, level, cid) {
    if (!cmd_access(id, level, cid, 1)) return PLUGIN_HANDLED;

    ArrayClear(kzru_QuestNames);
    ArrayClear(kzru_QuestTypes);
    ArrayClear(kzru_QuestParams);
    TrieClear(kzru_QuestSettings);
    kzru_GameQuests = 0;
    
    LoadKreedzQuestsConfig();
    
    client_print(id, print_console, "<Kreedz Quests> Конфигурация успешно перезагружена.");
    return PLUGIN_HANDLED;
}

public KreedzShowQuests(id) {
    new menu = menu_create("[KZRU] Доступные квесты", "menuQuestsHandler");
    
    for (new i = 0; i < kzru_GameQuests; i++) {
        new QuestName[32];
        ArrayGetString(kzru_QuestNames, i, QuestName, charsmax(QuestName));
        
        new enabled[2];
        TrieGetString(kzru_QuestSettings, fmt("%s_enabled", QuestName), enabled, charsmax(enabled));
        
        if (equal(enabled, "1")) {
            menu_additem(menu, QuestName);
        }
    }
    
    menu_display(id, menu);
    return PLUGIN_HANDLED;
}

public KreedzMenuQuestsHandler(id, menu, item) {
    if (item == MENU_EXIT) {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }
    
    new QuestName[32];
    menu_item_getinfo(menu, item, _, QuestName, charsmax(QuestName));
    
    KreedzShowQuestInfo(id, QuestName);
    return PLUGIN_HANDLED;
}

public KreedzShowQuestInfo(id, QuestName[]) {
    new iKreedzDescription[128], iKreedzReward[64];
    TrieGetString(kzru_QuestSettings, fmt("%s_description", QuestName), iKreedzDescription, charsmax(iKreedzDescription));
    TrieGetString(kzru_QuestSettings, fmt("%s_reward_money", QuestName), iKreedzReward, charsmax(iKreedzReward));
    
    client_print(id, print_chat, "<Kreedz Quests> %s: %s (Награда: $%s)", QuestName, iKreedzDescription, iKreedzReward);
}