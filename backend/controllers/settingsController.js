const Setting = require('../models/Setting');

// Get all settings (Admin only)
exports.getAllSettings = async (req, res) => {
  try {
    const { category } = req.query;
    
    let settings;
    if (category) {
      settings = await Setting.getByCategory(category);
    } else {
      settings = await Setting.getAllAsObject();
    }

    res.json({
      success: true,
      data: settings
    });
  } catch (error) {
    console.error('Error getting all settings:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể lấy danh sách cài đặt',
      error: error.message
    });
  }
};

// Get settings grouped by category
exports.getSettingsByCategory = async (req, res) => {
  try {
    const allSettings = await Setting.getAll();
    
    // Group by category
    const grouped = allSettings.reduce((acc, setting) => {
      if (!acc[setting.category]) {
        acc[setting.category] = [];
      }
      
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
      }
      
      acc[setting.category].push({
        key: setting.key,
        value: value,
        description: setting.description,
        dataType: setting.data_type
      });
      
      return acc;
    }, {});

    res.json({
      success: true,
      data: grouped
    });
  } catch (error) {
    console.error('Error getting settings by category:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể lấy cài đặt theo danh mục',
      error: error.message
    });
  }
};

// Get public settings (for frontend without auth)
exports.getPublicSettings = async (req, res) => {
  try {
    // Only return safe public settings
    const publicKeys = [
      'store_name',
      'store_email',
      'store_phone',
      'store_address',
      'store_description',
      'store_logo_url',
      'currency',
      'currency_symbol',
      'free_shipping_threshold',
      'shipping_regions',
      'estimated_delivery_days',
      'accept_cod',
      'accept_online_payment'
    ];

    const allSettings = await Setting.getAllAsObject();
    const publicSettings = {};

    publicKeys.forEach(key => {
      if (allSettings[key] !== undefined) {
        publicSettings[key] = allSettings[key];
      }
    });

    res.json({
      success: true,
      data: publicSettings
    });
  } catch (error) {
    console.error('Error getting public settings:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể lấy cài đặt công khai',
      error: error.message
    });
  }
};

// Get setting by key
exports.getSettingByKey = async (req, res) => {
  try {
    const { key } = req.params;
    const setting = await Setting.getByKey(key);

    if (!setting) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy cài đặt'
      });
    }

    res.json({
      success: true,
      data: setting
    });
  } catch (error) {
    console.error('Error getting setting by key:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể lấy cài đặt',
      error: error.message
    });
  }
};

// Update setting by key (Admin only)
exports.updateSetting = async (req, res) => {
  try {
    const { key } = req.params;
    const { value, description } = req.body;

    if (value === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu giá trị value'
      });
    }

    // Get current setting to validate data type
    const currentSetting = await Setting.getByKey(key);
    if (!currentSetting) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy cài đặt'
      });
    }

    // Validate value based on data type
    if (!Setting.validateValue(currentSetting.data_type, value)) {
      return res.status(400).json({
        success: false,
        message: `Giá trị không hợp lệ cho kiểu ${currentSetting.data_type}`
      });
    }

    const updatedSetting = await Setting.updateByKey(key, value, description);

    res.json({
      success: true,
      message: 'Đã cập nhật cài đặt',
      data: updatedSetting
    });
  } catch (error) {
    console.error('Error updating setting:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể cập nhật cài đặt',
      error: error.message
    });
  }
};

// Update multiple settings (Admin only)
exports.updateBulkSettings = async (req, res) => {
  try {
    const { settings } = req.body;

    if (!Array.isArray(settings) || settings.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'settings phải là một mảng không rỗng'
      });
    }

    // Validate all settings before updating
    for (const { key, value } of settings) {
      const currentSetting = await Setting.getByKey(key);
      if (!currentSetting) {
        return res.status(400).json({
          success: false,
          message: `Không tìm thấy cài đặt với key: ${key}`
        });
      }

      if (!Setting.validateValue(currentSetting.data_type, value)) {
        return res.status(400).json({
          success: false,
          message: `Giá trị không hợp lệ cho ${key} (kiểu ${currentSetting.data_type})`
        });
      }
    }

    const result = await Setting.updateBulk(settings);

    res.json({
      success: true,
      message: `Đã cập nhật ${result.updatedCount} cài đặt`,
      data: result
    });
  } catch (error) {
    console.error('Error updating bulk settings:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể cập nhật cài đặt',
      error: error.message
    });
  }
};

// Create new setting (Admin only)
exports.createSetting = async (req, res) => {
  try {
    const { key, value, description, category = 'system', dataType = 'string' } = req.body;

    if (!key || value === undefined) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu key hoặc value'
      });
    }

    // Check if setting already exists
    const existing = await Setting.getByKey(key);
    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'Cài đặt với key này đã tồn tại'
      });
    }

    const newSetting = await Setting.create({
      key,
      value,
      description,
      category,
      dataType
    });

    res.status(201).json({
      success: true,
      message: 'Đã tạo cài đặt mới',
      data: newSetting
    });
  } catch (error) {
    console.error('Error creating setting:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể tạo cài đặt',
      error: error.message
    });
  }
};

// Delete setting by key (Admin only)
exports.deleteSetting = async (req, res) => {
  try {
    const { key } = req.params;
    
    const success = await Setting.deleteByKey(key);

    if (!success) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy cài đặt'
      });
    }

    res.json({
      success: true,
      message: 'Đã xóa cài đặt'
    });
  } catch (error) {
    console.error('Error deleting setting:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể xóa cài đặt',
      error: error.message
    });
  }
};

// Reset settings to default (Admin only - use with caution)
exports.resetToDefaults = async (req, res) => {
  try {
    const { category } = req.body;
    
    // This is a dangerous operation - require confirmation
    const { confirm } = req.body;
    if (confirm !== 'RESET_SETTINGS') {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng xác nhận bằng cách gửi confirm: "RESET_SETTINGS"'
      });
    }

    // Get all settings or by category
    const settings = await Setting.getAll(category);
    
    // This would require re-running the migration SQL
    // For now, just return info about what would be reset
    res.json({
      success: true,
      message: 'Để reset cài đặt, vui lòng chạy lại migration create_settings_table.sql',
      data: {
        settingsToReset: settings.length,
        category: category || 'all'
      }
    });
  } catch (error) {
    console.error('Error resetting settings:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể reset cài đặt',
      error: error.message
    });
  }
};

// Get store information (public)
exports.getStoreInfo = async (req, res) => {
  try {
    const storeSettings = await Setting.getByCategory('store');

    res.json({
      success: true,
      data: storeSettings
    });
  } catch (error) {
    console.error('Error getting store info:', error);
    res.status(500).json({
      success: false,
      message: 'Không thể lấy thông tin cửa hàng',
      error: error.message
    });
  }
};
