import json
import sqlite3
from pathlib import Path

def parse_bookmarks(json_path):
    """解析书签JSON文件，返回扁平化的书签列表和父子关系"""
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # 从bookmark_bar获取书签数据（可根据需要扩展到其他根节点）
    root_children = data.get('roots', {}).get('bookmark_bar', {}).get('children', [])
    
    bookmarks = []  # 存储所有书签项
    relationships = []  # 存储父子关系 (parent_id, child_id)
    
    def recursive_parse(items, parent_id=None):
        """递归解析嵌套的书签项"""
        for item in items:
            # 提取基础信息
            bookmark = {
                'id': item.get('id'),
                'guid': item.get('guid'),
                'name': item.get('name', ''),
                'type': item.get('type'),
                'url': item.get('url', ''),
                'date_added': item.get('date_added', ''),
                'date_last_used': item.get('date_last_used', ''),
                'date_modified': item.get('date_modified', '')
            }
            bookmarks.append(bookmark)
            
            # 记录父子关系
            if parent_id is not None:
                relationships.append((parent_id, item.get('id')))
            
            # 如果是文件夹，递归处理子项
            if item.get('type') == 'folder' and 'children' in item:
                recursive_parse(item['children'], parent_id=item.get('id'))
    
    # 开始解析
    recursive_parse(root_children)
    return bookmarks, relationships

def init_database(db_path):
    """初始化数据库表结构"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # 创建书签表
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS bookmarks (
        id TEXT PRIMARY KEY,
        guid TEXT UNIQUE,
        name TEXT,
        type TEXT,
        url TEXT,
        date_added TEXT,
        date_last_used TEXT,
        date_modified TEXT
    )
    ''')
    
    # 创建父子关系表
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS bookmark_relationships (
        parent_id TEXT,
        child_id TEXT,
        FOREIGN KEY (parent_id) REFERENCES bookmarks(id),
        FOREIGN KEY (child_id) REFERENCES bookmarks(id),
        PRIMARY KEY (parent_id, child_id)
    )
    ''')
    
    conn.commit()
    conn.close()

def import_to_database(bookmarks, relationships, db_path):
    """将解析后的数据导入数据库"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # 插入书签数据
    bookmark_sql = '''
    INSERT OR IGNORE INTO bookmarks 
    (id, guid, name, type, url, date_added, date_last_used, date_modified)
    VALUES (:id, :guid, :name, :type, :url, :date_added, :date_last_used, :date_modified)
    '''
    cursor.executemany(bookmark_sql, bookmarks)
    
    # 插入父子关系
    if relationships:
        rel_sql = '''
        INSERT OR IGNORE INTO bookmark_relationships (parent_id, child_id)
        VALUES (?, ?)
        '''
        cursor.executemany(rel_sql, relationships)
    
    conn.commit()
    conn.close()

if __name__ == '__main__':
    # 配置路径
    json_file = Path('Bookmarks.json')  # 你的书签JSON文件路径
    db_file = Path('bookmarks.db')      # 生成的数据库文件路径
    
    # 检查文件是否存在
    if not json_file.exists():
        print(f"错误：未找到文件 {json_file}")
        exit(1)
    
    # 执行流程
    print("解析书签文件...")
    bookmarks, relationships = parse_bookmarks(json_file)
    
    print("初始化数据库...")
    init_database(db_file)
    
    print(f"导入 {len(bookmarks)} 个书签项...")
    import_to_database(bookmarks, relationships, db_file)
    
    print(f"操作完成，数据已导入 {db_file}")
