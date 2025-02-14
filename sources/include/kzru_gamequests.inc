#if defined _kreedz_quests_included
    #endinput
#endif
#define _kreedz_quests_included

// Регистрация нового типа квеста
native KZRU_RegisterQuest(const quest_type[], const iKreedzDescription[], quest_start_callback, quest_progress_callback, quest_complete_callback);

// Callbacks для обработки квестов
forward quest_start_callback(playerid, const quest_name[]);
forward quest_progress_callback(playerid, const quest_name[], Float:progress);
forward quest_complete_callback(playerid, const quest_name[]);

// Получение значения настройки квеста
native KZRU_GetQuestSetting(const quest_name[], const setting_name[], iKreedzValue[], len);

// Установка значения настройки квеста для игрока
native KZRU_SetPlayerQuestData(playerid, const quest_name[], const iKreedzKey[], const iKreedzValue[]);

// Получение значения настройки квеста для игрока
native KZRU_GetPlayerQuestData(playerid, const quest_name[], const iKreedzKey[], iKreedzValue[], len);

// Завершение квеста для игрока
native KZRU_CompleteQuest(playerid, const quest_name[]);

// Выдача награды игроку
native KZRU_GiveReward(playerid, const quest_name[]);

// Проверка активности квеста
native bool:KZRU_IsQuestActive(const quest_name[]);

// Получение текущего прогресса игрока в квесте
native Float:KZRU_GetQuestProgress(playerid, const quest_name[]);