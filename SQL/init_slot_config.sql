-- 初始化示例Slot配置
-- 这个脚本创建一个标准的5x3老虎机配置和一个Megaway配置

-- 创建标准5x3老虎机配置
INSERT INTO slot_configurations (
    name, rows, reels, is_megaway, min_megaway_rows, max_megaway_rows,
    default_bet, min_bet, max_bet, wild_enabled, free_spins_enabled, rtp_percentage
) VALUES (
    'Lucky Fruits 5x3', 3, 5, false, 2, 7,
    1, 1, 100, true, true, 96.50
);

-- 获取刚插入的配置ID
DO $$
DECLARE 
    config_id INTEGER;
    cherry_id INTEGER;
    lemon_id INTEGER;
    orange_id INTEGER;
    plum_id INTEGER;
    bell_id INTEGER;
    bar_id INTEGER;
    seven_id INTEGER;
    wild_id INTEGER;
    scatter_id INTEGER;
BEGIN
    -- 获取配置ID
    SELECT id INTO config_id FROM slot_configurations WHERE name = 'Lucky Fruits 5x3';
    
    -- 插入符号
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x)
    VALUES (config_id, 'Cherry', 'normal', 1, 5, 10, 20) RETURNING id INTO cherry_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x)
    VALUES (config_id, 'Lemon', 'normal', 2, 10, 20, 40) RETURNING id INTO lemon_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x)
    VALUES (config_id, 'Orange', 'normal', 3, 15, 30, 60) RETURNING id INTO orange_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x)
    VALUES (config_id, 'Plum', 'normal', 4, 20, 40, 80) RETURNING id INTO plum_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x)
    VALUES (config_id, 'Bell', 'normal', 5, 25, 50, 100) RETURNING id INTO bell_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x)
    VALUES (config_id, 'Bar', 'normal', 6, 30, 60, 120) RETURNING id INTO bar_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x)
    VALUES (config_id, 'Seven', 'normal', 7, 50, 100, 200) RETURNING id INTO seven_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value)
    VALUES (config_id, 'Wild', 'wild', 0) RETURNING id INTO wild_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value)
    VALUES (config_id, 'Scatter', 'scatter', 0) RETURNING id INTO scatter_id;
    
    -- 配置卷轴（每个卷轴20个位置）
    -- 卷轴0
    INSERT INTO slot_reel_symbols (slot_config_id, reel_number, position, symbol_id, weight) VALUES
    (config_id, 0, 0, cherry_id, 3),
    (config_id, 0, 1, lemon_id, 3),
    (config_id, 0, 2, orange_id, 2),
    (config_id, 0, 3, plum_id, 2),
    (config_id, 0, 4, bell_id, 2),
    (config_id, 0, 5, cherry_id, 3),
    (config_id, 0, 6, lemon_id, 3),
    (config_id, 0, 7, bar_id, 1),
    (config_id, 0, 8, seven_id, 1),
    (config_id, 0, 9, wild_id, 1),
    (config_id, 0, 10, cherry_id, 3),
    (config_id, 0, 11, lemon_id, 3),
    (config_id, 0, 12, orange_id, 2),
    (config_id, 0, 13, plum_id, 2),
    (config_id, 0, 14, scatter_id, 1),
    (config_id, 0, 15, cherry_id, 3),
    (config_id, 0, 16, lemon_id, 3),
    (config_id, 0, 17, orange_id, 2),
    (config_id, 0, 18, bell_id, 2),
    (config_id, 0, 19, plum_id, 2);
    
    -- 卷轴1-4使用类似的配置（略有变化）
    -- 这里只是示例，实际游戏中每个卷轴的符号分布应该精心设计
    FOR reel IN 1..4 LOOP
        FOR pos IN 0..19 LOOP
            INSERT INTO slot_reel_symbols (slot_config_id, reel_number, position, symbol_id, weight)
            VALUES (
                config_id, 
                reel, 
                pos,
                CASE 
                    WHEN pos % 5 = 0 THEN cherry_id
                    WHEN pos % 5 = 1 THEN lemon_id
                    WHEN pos % 5 = 2 THEN orange_id
                    WHEN pos % 5 = 3 THEN plum_id
                    WHEN pos % 5 = 4 THEN bell_id
                    WHEN pos = 7 THEN bar_id
                    WHEN pos = 9 THEN seven_id
                    WHEN pos = 11 THEN wild_id
                    WHEN pos = 14 THEN scatter_id
                    ELSE cherry_id
                END,
                CASE 
                    WHEN pos < 5 THEN 3
                    WHEN pos < 10 THEN 2
                    ELSE 1
                END
            );
        END LOOP;
    END LOOP;
    
    -- 配置支付线（9条标准支付线）
    -- 第1条：中间横线
    INSERT INTO slot_paylines (slot_config_id, line_number, pattern, is_active)
    VALUES (config_id, 1, '[[0,1],[1,1],[2,1],[3,1],[4,1]]'::jsonb, true);
    
    -- 第2条：上横线
    INSERT INTO slot_paylines (slot_config_id, line_number, pattern, is_active)
    VALUES (config_id, 2, '[[0,0],[1,0],[2,0],[3,0],[4,0]]'::jsonb, true);
    
    -- 第3条：下横线
    INSERT INTO slot_paylines (slot_config_id, line_number, pattern, is_active)
    VALUES (config_id, 3, '[[0,2],[1,2],[2,2],[3,2],[4,2]]'::jsonb, true);
    
    -- 第4条：V形
    INSERT INTO slot_paylines (slot_config_id, line_number, pattern, is_active)
    VALUES (config_id, 4, '[[0,0],[1,1],[2,2],[3,1],[4,0]]'::jsonb, true);
    
    -- 第5条：倒V形
    INSERT INTO slot_paylines (slot_config_id, line_number, pattern, is_active)
    VALUES (config_id, 5, '[[0,2],[1,1],[2,0],[3,1],[4,2]]'::jsonb, true);
    
    -- 第6条：之字形1
    INSERT INTO slot_paylines (slot_config_id, line_number, pattern, is_active)
    VALUES (config_id, 6, '[[0,1],[1,0],[2,1],[3,2],[4,1]]'::jsonb, true);
    
    -- 第7条：之字形2
    INSERT INTO slot_paylines (slot_config_id, line_number, pattern, is_active)
    VALUES (config_id, 7, '[[0,1],[1,2],[2,1],[3,0],[4,1]]'::jsonb, true);
    
    -- 第8条：上V形
    INSERT INTO slot_paylines (slot_config_id, line_number, pattern, is_active)
    VALUES (config_id, 8, '[[0,0],[1,0],[2,1],[3,0],[4,0]]'::jsonb, true);
    
    -- 第9条：下V形
    INSERT INTO slot_paylines (slot_config_id, line_number, pattern, is_active)
    VALUES (config_id, 9, '[[0,2],[1,2],[2,1],[3,2],[4,2]]'::jsonb, true);
    
END $$;

-- 创建Megaway配置
INSERT INTO slot_configurations (
    name, rows, reels, is_megaway, min_megaway_rows, max_megaway_rows,
    default_bet, min_bet, max_bet, wild_enabled, free_spins_enabled, rtp_percentage
) VALUES (
    'Megaway Fortune', 6, 6, true, 2, 7,
    1, 1, 500, true, true, 96.00
);

-- 为Megaway配置添加符号
DO $$
DECLARE 
    megaway_config_id INTEGER;
    gem_red_id INTEGER;
    gem_blue_id INTEGER;
    gem_green_id INTEGER;
    gem_purple_id INTEGER;
    gem_yellow_id INTEGER;
    gem_diamond_id INTEGER;
    megaway_wild_id INTEGER;
    megaway_scatter_id INTEGER;
BEGIN
    -- 获取Megaway配置ID
    SELECT id INTO megaway_config_id FROM slot_configurations WHERE name = 'Megaway Fortune';
    
    -- 插入宝石主题符号
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x, payout_6x)
    VALUES (megaway_config_id, 'Red Gem', 'normal', 1, 2, 5, 10, 20) RETURNING id INTO gem_red_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x, payout_6x)
    VALUES (megaway_config_id, 'Blue Gem', 'normal', 2, 3, 8, 15, 30) RETURNING id INTO gem_blue_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x, payout_6x)
    VALUES (megaway_config_id, 'Green Gem', 'normal', 3, 5, 10, 20, 40) RETURNING id INTO gem_green_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x, payout_6x)
    VALUES (megaway_config_id, 'Purple Gem', 'normal', 4, 8, 15, 30, 60) RETURNING id INTO gem_purple_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x, payout_6x)
    VALUES (megaway_config_id, 'Yellow Gem', 'normal', 5, 10, 20, 40, 80) RETURNING id INTO gem_yellow_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value, payout_3x, payout_4x, payout_5x, payout_6x)
    VALUES (megaway_config_id, 'Diamond', 'normal', 6, 20, 50, 100, 200) RETURNING id INTO gem_diamond_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value)
    VALUES (megaway_config_id, 'Wild Star', 'wild', 0) RETURNING id INTO megaway_wild_id;
    
    INSERT INTO slot_symbols (slot_config_id, name, symbol_type, value)
    VALUES (megaway_config_id, 'Scatter Bonus', 'scatter', 0) RETURNING id INTO megaway_scatter_id;
    
    -- 配置Megaway卷轴（每个卷轴配置较多符号以支持不同行数）
    FOR reel IN 0..5 LOOP
        FOR pos IN 0..29 LOOP
            INSERT INTO slot_reel_symbols (slot_config_id, reel_number, position, symbol_id, weight)
            VALUES (
                megaway_config_id, 
                reel, 
                pos,
                CASE 
                    WHEN pos % 6 = 0 THEN gem_red_id
                    WHEN pos % 6 = 1 THEN gem_blue_id
                    WHEN pos % 6 = 2 THEN gem_green_id
                    WHEN pos % 6 = 3 THEN gem_purple_id
                    WHEN pos % 6 = 4 THEN gem_yellow_id
                    WHEN pos % 6 = 5 THEN gem_diamond_id
                    WHEN pos = 10 THEN megaway_wild_id
                    WHEN pos = 20 THEN megaway_scatter_id
                    ELSE gem_red_id
                END,
                CASE 
                    WHEN pos < 10 THEN 4
                    WHEN pos < 20 THEN 3
                    ELSE 2
                END
            );
        END LOOP;
    END LOOP;
    
    -- Megaway不需要固定的支付线，因为它使用所有可能的路径
    
END $$;