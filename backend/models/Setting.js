const pool = require('../config/database');

class Setting {
  // Get all settings
  static async getAll(category = null) {
    let query = 'SELECT * FROM settings';
    const params = [];
    
    if (category) {
      query += ' WHERE category = ?';
      params.push(category);
    }
    
    query += ' ORDER BY category, `key`';
    
    const [rows] = await pool.query(query, params);
    return rows;
  }

  // Get all settings as key-value object
  static async getAllAsObject(category = null) {
    const settings = await this.getAll(category);
    const settingsObj = {};
    
    settings.forEach(setting => {
      // Parse value based on data_type
      let value = setting.value;
      
      switch (setting.data_type) {
        case 'number':
          value = parseFloat(value);
          break;
        case 'boolean':
          value = value === 'true' || value === '1' || value === 1;
          break;
        case 'json':
          try {
            value = JSON.parse(value);
          } catch (e) {
            console.error(`Error parsing JSON for key ${setting.key}:`, e);
          }
          break;
        default:
          // string - keep as is
          break;
      }
      
      settingsObj[setting.key] = value;
    });
    
    return settingsObj;
  }

  // Get setting by key
  static async getByKey(key) {
    const [rows] = await pool.query(
      'SELECT * FROM settings WHERE `key` = ?',
      [key]
    );
    
    if (rows.length === 0) {
      return null;
    }
    
    const setting = rows[0];
    
    // Parse value based on data_type
    let value = setting.value;
    switch (setting.data_type) {
      case 'number':
        value = parseFloat(value);
        break;
      case 'boolean':
        value = value === 'true' || value === '1' || value === 1;
        break;
      case 'json':
        try {
          value = JSON.parse(value);
        } catch (e) {
          console.error(`Error parsing JSON for key ${key}:`, e);
        }
        break;
    }
    
    return { ...setting, parsedValue: value };
  }

  // Get setting value directly
  static async getValue(key, defaultValue = null) {
    const setting = await this.getByKey(key);
    return setting ? setting.parsedValue : defaultValue;
  }

  // Update setting by key
  static async updateByKey(key, value, description = null) {
    const setting = await this.getByKey(key);
    
    if (!setting) {
      throw new Error(`Setting with key '${key}' not found`);
    }

    // Convert value to string based on data_type
    let stringValue = value;
    
    if (setting.data_type === 'json') {
      if (typeof value === 'object') {
        stringValue = JSON.stringify(value);
      }
    } else if (setting.data_type === 'boolean') {
      stringValue = value ? 'true' : 'false';
    } else if (setting.data_type === 'number') {
      stringValue = String(value);
    }

    const updates = ['value = ?'];
    const params = [stringValue];

    if (description !== null) {
      updates.push('description = ?');
      params.push(description);
    }

    params.push(key);

    await pool.query(
      `UPDATE settings SET ${updates.join(', ')} WHERE \`key\` = ?`,
      params
    );

    return this.getByKey(key);
  }

  // Create new setting
  static async create(settingData) {
    const { key, value, description = null, category = 'system', dataType = 'string' } = settingData;
    
    if (!key || value === undefined) {
      throw new Error('Missing required fields: key, value');
    }

    const validCategories = ['store', 'payment', 'shipping', 'notification', 'email', 'system'];
    if (!validCategories.includes(category)) {
      throw new Error(`Invalid category. Must be one of: ${validCategories.join(', ')}`);
    }

    const validDataTypes = ['string', 'number', 'boolean', 'json'];
    if (!validDataTypes.includes(dataType)) {
      throw new Error(`Invalid data_type. Must be one of: ${validDataTypes.join(', ')}`);
    }

    // Convert value to string
    let stringValue = value;
    if (dataType === 'json' && typeof value === 'object') {
      stringValue = JSON.stringify(value);
    } else if (dataType === 'boolean') {
      stringValue = value ? 'true' : 'false';
    } else if (dataType === 'number') {
      stringValue = String(value);
    }

    await pool.query(
      `INSERT INTO settings (\`key\`, value, description, category, data_type) 
       VALUES (?, ?, ?, ?, ?)`,
      [key, stringValue, description, category, dataType]
    );

    return this.getByKey(key);
  }

  // Update multiple settings at once
  static async updateBulk(settings) {
    if (!Array.isArray(settings) || settings.length === 0) {
      throw new Error('settings must be a non-empty array');
    }

    const connection = await pool.getConnection();
    
    try {
      await connection.beginTransaction();

      for (const { key, value } of settings) {
        const setting = await this.getByKey(key);
        
        if (setting) {
          // Convert value to string based on data_type
          let stringValue = value;
          
          if (setting.data_type === 'json' && typeof value === 'object') {
            stringValue = JSON.stringify(value);
          } else if (setting.data_type === 'boolean') {
            stringValue = value ? 'true' : 'false';
          } else if (setting.data_type === 'number') {
            stringValue = String(value);
          }

          await connection.query(
            'UPDATE settings SET value = ? WHERE `key` = ?',
            [stringValue, key]
          );
        }
      }

      await connection.commit();
      return { success: true, updatedCount: settings.length };
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  // Delete setting by key
  static async deleteByKey(key) {
    const [result] = await pool.query(
      'DELETE FROM settings WHERE `key` = ?',
      [key]
    );
    return result.affectedRows > 0;
  }

  // Get settings by category
  static async getByCategory(category) {
    const validCategories = ['store', 'payment', 'shipping', 'notification', 'email', 'system'];
    if (!validCategories.includes(category)) {
      throw new Error(`Invalid category. Must be one of: ${validCategories.join(', ')}`);
    }

    return this.getAllAsObject(category);
  }

  // Validate setting value
  static validateValue(dataType, value) {
    switch (dataType) {
      case 'number':
        return !isNaN(parseFloat(value));
      case 'boolean':
        return ['true', 'false', '1', '0', true, false, 1, 0].includes(value);
      case 'json':
        try {
          JSON.parse(typeof value === 'object' ? JSON.stringify(value) : value);
          return true;
        } catch (e) {
          return false;
        }
      case 'string':
      default:
        return typeof value === 'string' || value !== null;
    }
  }
}

module.exports = Setting;
