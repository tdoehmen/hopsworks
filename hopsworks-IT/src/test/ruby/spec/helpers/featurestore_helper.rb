=begin
 This file is part of Hopsworks
 Copyright (C) 2018, Logical Clocks AB. All rights reserved

 Hopsworks is free software: you can redistribute it and/or modify it under the terms of
 the GNU Affero General Public License as published by the Free Software Foundation,
 either version 3 of the License, or (at your option) any later version.

 Hopsworks is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 PURPOSE.  See the GNU Affero General Public License for more details.

 You should have received a copy of the GNU Affero General Public License along with this program.
 If not, see <https://www.gnu.org/licenses/>.
=end

module FeaturestoreHelper

  def get_featurestore_id(project_id)
    list_project_featurestores_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/"
    get list_project_featurestores_endpoint
    parsed_json = JSON.parse(response.body)
    featurestore_id = parsed_json[0]["featurestoreId"]
    return featurestore_id
  end

  def create_cached_featuregroup_checked(project_id, featurestore_id, featuregroup_name, features: nil,
                                         featuregroup_description: nil)
    pp "create featuregroup:#{featuregroup_name}" if defined?(@debugOpt) && @debugOpt == true
    json_result, f_name = create_cached_featuregroup(project_id, featurestore_id, featuregroup_name: featuregroup_name,
                                                     features: features, featuregroup_description: featuregroup_description)
    expect_status_details(201)
    parsed_json = JSON.parse(json_result, :symbolize_names => true)
    parsed_json[:id]
  end

  def create_cached_featuregroup(project_id, featurestore_id, features: nil, featuregroup_name: nil, online:false,
                                 default_stats_settings: true, version: 1, featuregroup_description: nil)
    type = "cachedFeaturegroupDTO"
    if features == nil
      features = [
          {
              type: "INT",
              name: "testfeature",
              description: "testfeaturedescription",
              primary: true,
              onlineType: "INT",
              partition: false
          },
      ]
      if online
        features[0]['onlineType'] = "INT(11)"
      end
    end
    if featuregroup_name == nil
      featuregroup_name = "featuregroup_#{random_id}"
    end
    create_featuregroup_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/featuregroups"
    if featuregroup_description == nil
      featuregroup_description = "testfeaturegroupdescription"
    end
    json_data = {
        name: featuregroup_name,
        jobs: [],
        features: features,
        description: featuregroup_description,
        version: version,
        type: type,
        onlineEnabled: online
    }
    unless default_stats_settings
      json_data['numBins'] = 10
      json_data['numClusters'] = 10
      json_data['corrMethod'] = "spearman"
      json_data['featHistEnabled'] = false
      json_data['featCorrEnabled'] = false
      json_data['clusterAnalysisEnabled'] = false
      json_data['statisticColumns'] = ["testfeature"]
      json_data['descStatsEnabled'] = false
    end
    json_data = json_data.to_json
    json_result = post create_featuregroup_endpoint, json_data
    return json_result, featuregroup_name
  end

  def create_hopsfs_connector(project_id, featurestore_id, datasetName: "Resources")
    type = "featurestoreHopsfsConnectorDTO"
    storageConnectorType = "HopsFS"
    create_hopsfs_connector_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/storageconnectors/HOPSFS"
    hopsfs_connector_name = "hopsfs_connector_#{random_id}"
    json_data = {
        name: hopsfs_connector_name,
        description: "testhopsfsconnectordescription",
        type: type,
        storageConnectorType: storageConnectorType,
        datasetName: datasetName
    }
    json_data = json_data.to_json
    json_result = post create_hopsfs_connector_endpoint, json_data
    return json_result, hopsfs_connector_name
  end

  def update_hopsfs_connector(project_id, featurestore_id, connector_id, datasetName: "Resources")
    type = "featurestoreHopsfsConnectorDTO"
    storageConnectorType = "HopsFS"
    update_hopsfs_connector_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/storageconnectors/HOPSFS/" + connector_id.to_s
    hopsfs_connector_name = "hopsfs_connector_#{random_id}"
    json_data = {
        name: hopsfs_connector_name,
        description: "testhopsfsconnectordescription",
        type: type,
        storageConnectorType: storageConnectorType,
        datasetName: datasetName
    }
    json_data = json_data.to_json
    json_result = put update_hopsfs_connector_endpoint, json_data
    return json_result, hopsfs_connector_name
  end

  def create_jdbc_connector(project_id, featurestore_id, connectionString: "jdbc://test")
    type = "featurestoreJdbcConnectorDTO"
    storageConnectorType = "JDBC"
    create_jdbc_connector_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/storageconnectors/JDBC"
    jdbc_connector_name = "jdbc_connector_#{random_id}"
    json_data = {
        name: jdbc_connector_name,
        description: "testfeaturegroupdescription",
        type: type,
        storageConnectorType: storageConnectorType,
        connectionString: connectionString,
        arguments: "test1,test2"
    }
    json_data = json_data.to_json
    json_result = post create_jdbc_connector_endpoint, json_data
    return json_result, jdbc_connector_name
  end

  def update_jdbc_connector(project_id, featurestore_id, connector_id, connectionString: "jdbc://test")
    type = "featurestoreJdbcConnectorDTO"
    storageConnectorType = "JDBC"
    update_jdbc_connector_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/storageconnectors/JDBC/" + connector_id.to_s
    jdbc_connector_name = "jdbc_connector_#{random_id}"
    json_data = {
        name: jdbc_connector_name,
        description: "testfeaturegroupdescription",
        type: type,
        storageConnectorType: storageConnectorType,
        connectionString: connectionString,
        arguments: "test1,test2"
    }
    json_data = json_data.to_json
    json_result = put update_jdbc_connector_endpoint, json_data
    return json_result, jdbc_connector_name
  end

  def create_s3_connector(project_id, featurestore_id, bucket: "test")
    type = "featurestoreS3ConnectorDTO"
    storageConnectorType = "S3"
    create_s3_connector_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/storageconnectors/S3"
    s3_connector_name = "s3_connector_#{random_id}"
    json_data = {
        name: s3_connector_name,
        description: "tests3connectordescription",
        type: type,
        storageConnectorType: storageConnectorType,
        bucket: bucket,
        secretKey: "test",
        accessKey: "test"
    }
    json_data = json_data.to_json
    json_result = post create_s3_connector_endpoint, json_data
    return json_result, s3_connector_name
  end

  def update_s3_connector(project_id, featurestore_id, connector_id, bucket: "test")
    type = "featurestoreS3ConnectorDTO"
    storageConnectorType = "S3"
    update_s3_connector_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/storageconnectors/S3/" + connector_id.to_s
    s3_connector_name = "s3_connector_#{random_id}"
    json_data = {
        name: s3_connector_name,
        description: "tests3connectordescription",
        type: type,
        storageConnectorType: storageConnectorType,
        bucket: bucket,
        secretKey: "test",
        accessKey: "test"
    }
    json_data = json_data.to_json
    json_result = put update_s3_connector_endpoint, json_data
    return json_result, s3_connector_name
  end

  def create_on_demand_featuregroup(project_id, featurestore_id, jdbcconnectorId, name: nil, query: nil)
    type = "onDemandFeaturegroupDTO"
    featuregroupType = "ON_DEMAND_FEATURE_GROUP"
    create_featuregroup_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/featuregroups"
    if name == nil
      featuregroup_name = "featuregroup_#{random_id}"
    else
      featuregroup_name = name
    end
    if query == nil
      query = "SELECT * FROM test"
    end
    json_data = {
        name: featuregroup_name,
        jobs: [],
        features: [
            {
                type: "INT",
                name: "testfeature",
                description: "testfeaturedescription",
                primary: true
            }
        ],
        description: "testfeaturegroupdescription",
        version: 1,
        type: type,
        jdbcConnectorId: jdbcconnectorId,
        query: query,
        featuregroupType: featuregroupType
    }
    json_data = json_data.to_json
    json_result = post create_featuregroup_endpoint, json_data
    return json_result, featuregroup_name
  end

  def update_on_demand_featuregroup(project_id, featurestore_id, jdbcconnectorId, featuregroup_id,
                                    featuregroup_version, query: nil, featuregroup_name: nil, featuregroup_desc: nil)
    type = "onDemandFeaturegroupDTO"
    featuregroupType = "ON_DEMAND_FEATURE_GROUP"
    update_featuregroup_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/featuregroups/" + featuregroup_id.to_s + "?updateMetadata=true"
    if featuregroup_name == nil
      featuregroup_name = "featuregroup_#{random_id}"
    end
    if featuregroup_desc == nil
      featuregroup_desc = "description_#{random_id}"
    end
    if query == nil
      query = "SELECT * FROM test"
    end
    json_data = {
        name: featuregroup_name,
        jobs: [],
        features: [
            {
                type: "INT",
                name: "testfeature",
                description: "testfeaturedescription",
                primary: true
            }
        ],
        description: featuregroup_desc,
        version: featuregroup_version,
        type: type,
        jdbcConnectorId: jdbcconnectorId,
        query: query,
        featuregroupType: featuregroupType
    }
    json_data = json_data.to_json
    json_result = put update_featuregroup_endpoint, json_data
    return json_result, featuregroup_name
  end

  def update_cached_featuregroup_metadata(project_id, featurestore_id, featuregroup_id, featuregroup_version)
    type = "cachedFeaturegroupDTO"
    featuregroupType = "CACHED_FEATURE_GROUP"
    update_featuregroup_metadata_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/featuregroups/" + featuregroup_id.to_s + "?updateMetadata=true"
    json_data = {
        name: "",
        jobs: [],
        features: [],
        description: "",
        version: featuregroup_version,
        type: type,
        featuregroupType: featuregroupType
    }
    json_data = json_data.to_json
    json_result = put update_featuregroup_metadata_endpoint, json_data
    return json_result
  end

  def update_cached_featuregroup_stats_settings(project_id, featurestore_id, featuregroup_id, featuregroup_version)
    type = "cachedFeaturegroupDTO"
    featuregroupType = "CACHED_FEATURE_GROUP"
    update_featuregroup_metadata_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/featuregroups/" + featuregroup_id.to_s + "?updateStatsSettings=true"
    json_data = {
        type: type,
        featuregroupType: featuregroupType,
        version: featuregroup_version,
        numBins: 10,
        numClusters: 10,
        corrMethod: "spearman",
        featHistEnabled: false,
        featCorrEnabled: false,
        clusterAnalysisEnabled: false,
        statisticColumns: ["testfeature"],
        descStatsEnabled: false
    }
    json_data = json_data.to_json
    json_result = put update_featuregroup_metadata_endpoint, json_data
    return json_result
  end

  def enable_cached_featuregroup_online(project_id, featurestore_id, featuregroup_id, featuregroup_version)
    type = "cachedFeaturegroupDTO"
    enable_featuregroup_online_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/featuregroups/" + featuregroup_id.to_s + "?enableOnline=true"
    json_data = {
        name: "",
        jobs: [],
        features: [
            {
                type: "INT",
                name: "testfeature",
                description: "testfeaturedescription",
                primary: true,
                partition: false,
                onlineType: "INT(11)"
            }
        ],
        description: "",
        version: featuregroup_version,
        onlineEnabled: true,
        type: type
    }
    json_data = json_data.to_json
    json_result = put enable_featuregroup_online_endpoint, json_data
    return json_result
  end

  def disable_cached_featuregroup_online(project_id, featurestore_id, featuregroup_id, featuregroup_version)
    type = "cachedFeaturegroupDTO"
    disable_featuregroup_online_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/featuregroups/" + featuregroup_id.to_s + "?disableOnline=true"
    json_data = {
        name: "",
        jobs: [],
        features: [],
        description: "",
        version: featuregroup_version,
        onlineEnabled: false,
        type: type
    }
    json_data = json_data.to_json
    json_result = put disable_featuregroup_online_endpoint, json_data
    return json_result
  end

  def update_hopsfs_training_dataset_metadata(project_id, featurestore_id, training_dataset_id, dataFormat,
                                              hopsfs_connector, jobs: nil)
    trainingDatasetType = "HOPSFS_TRAINING_DATASET"
    update_training_dataset_metadata_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/trainingdatasets/" + training_dataset_id.to_s + "?updateMetadata=true"
    json_data = {
        name: "new_dataset_name",
        jobs: jobs,
        description: "new_testtrainingdatasetdescription",
        version: 1,
        dataFormat: dataFormat,
        trainingDatasetType: trainingDatasetType,
        storageConnectorId: hopsfs_connector.id
    }
    json_data = json_data.to_json
    json_result = put update_training_dataset_metadata_endpoint, json_data
    return json_result
  end

  def update_external_training_dataset_metadata(project_id, featurestore_id, training_dataset_id, name,
                                                description, s3_connector_id)
    trainingDatasetType = "EXTERNAL_TRAINING_DATASET"
    update_training_dataset_metadata_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/trainingdatasets/" + training_dataset_id.to_s + "?updateMetadata=true"
    json_data = {
        name: name,
        jobs: [],
        description: description,
        version: 1,
        dataFormat: "parquet",
        trainingDatasetType: trainingDatasetType,
        storageConnectorId: s3_connector_id
    }
    json_data = json_data.to_json
    json_result = put update_training_dataset_metadata_endpoint, json_data
    return json_result
  end

  def create_hopsfs_training_dataset_checked(project_id, featurestore_id, connector, training_dataset_name, features: nil , description: nil)
    pp "create training dataset:#{training_dataset_name}" if defined?(@debugOpt) && @debugOpt == true
    json_result, training_dataset_name_aux = create_hopsfs_training_dataset(project_id, featurestore_id, connector, name:training_dataset_name, features: features, description: description)
    expect_status_details(201)
    parsed_json = JSON.parse(json_result, :symbolize_names => true)
    parsed_json
  end

  def create_hopsfs_training_dataset(project_id, featurestore_id, hopsfs_connector, name:nil, data_format: nil,
                                     version: 1, splits: [], features: nil, description: nil)
    trainingDatasetType = "HOPSFS_TRAINING_DATASET"
    create_training_dataset_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/trainingdatasets"
    if name == nil
      training_dataset_name = "training_dataset_#{random_id}"
    else
      training_dataset_name = name
    end
    if data_format == nil
      data_format = "tfrecords"
    end
    if hopsfs_connector == nil
      connector_id = nil
      connector_name = nil
    else
      connector_id = hopsfs_connector.id
      connector_name = hopsfs_connector.name
    end
    if features == nil
      features = [
          {
              type: "INT",
              name: "testfeature",
              description: "testfeaturedescription"
          },
          {
              type: "INT",
              name: "testfeature2",
              description: "testfeaturedescription2"
          }
      ]
    end
    if description == nil
      description = "testtrainingdatasetdescription"
    end
    json_data = {
        name: training_dataset_name,
        jobs: [],
        description: description,
        version: version,
        dataFormat: data_format,
        trainingDatasetType: trainingDatasetType,
        storageConnectorId: connector_id,
        storageConnectorName: connector_name,
        features: features,
        splits: splits,
        seed: 1234
    }
    json_data = json_data.to_json
    json_result = post create_training_dataset_endpoint, json_data
    return json_result, training_dataset_name
  end

  def create_external_training_dataset(project_id, featurestore_id, s3_connector_id, name: nil, location: "", splits:[])
    trainingDatasetType = "EXTERNAL_TRAINING_DATASET"
    create_training_dataset_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/trainingdatasets"
    if name == nil
      training_dataset_name = "training_dataset_#{random_id}"
    else
      training_dataset_name = name
    end
    json_data = {
        name: training_dataset_name,
        jobs: [],
        description: "testtrainingdatasetdescription",
        version: 1,
        dataFormat: "tfrecords",
        location: location,
        trainingDatasetType: trainingDatasetType,
        storageConnectorId: s3_connector_id,
        features: [
            {
                type: "INT",
                name: "testfeature",
                description: "testfeaturedescription"
            },
            {
                type: "INT",
                name: "testfeature2",
                description: "testfeaturedescription2"
            }
        ],
        splits: splits,
        seed: 1234
    }
    json_data = json_data.to_json
    json_result = post create_training_dataset_endpoint, json_data
    return json_result, training_dataset_name
  end

  def get_featurestore_tour_job_name
    return "featurestore_tour_job"
  end

  def create_cached_featuregroup_with_partition(project_id, featurestore_id)
    type = "cachedFeaturegroupDTO"
    featuregroupType = "CACHED_FEATURE_GROUP"
    create_featuregroup_endpoint = "#{ENV['HOPSWORKS_API']}/project/" + project_id.to_s + "/featurestores/" + featurestore_id.to_s + "/featuregroups"
    featuregroup_name = "featuregroup_#{random_id}"
    json_data = {
        name: featuregroup_name,
        jobs: [],
        features: [
            {
                type: "INT",
                name: "testfeature",
                description: "testfeaturedescription",
                primary: true,
                partition: false
            },
            {
                type: "INT",
                name: "testfeature2",
                description: "testfeaturedescription2",
                primary: false,
                partition: true
            }
        ],
        description: "testfeaturegroupdescription",
        version: 1,
        type: type,
        featuregroupType: featuregroupType
    }
    json_data = json_data.to_json
    json_result = post create_featuregroup_endpoint, json_data
    return json_result, featuregroup_name
  end

  def with_jdbc_connector(project_id)
    featurestore_id = get_featurestore_id(project_id)
    json_result, connector_name = create_jdbc_connector(project_id, featurestore_id, connectionString: "jdbc://test2")
    parsed_json = JSON.parse(json_result)
    expect_status(201)
    connector_id = parsed_json["id"]
    @jdbc_connector_id = connector_id
  end

  def get_jdbc_connector_id
    return @jdbc_connector_id
  end

  def get_hopsfs_training_datasets_connector(project_name)
    connector_name = project_name + "_Training_Datasets"
    return FeatureStoreHopsfsConnector.find_by(name: connector_name)
  end

  def get_s3_connector_id
    return @s3_connector_id
  end

  def with_s3_connector(project_id)
    featurestore_id = get_featurestore_id(project_id)
    json_result, connector_name = create_s3_connector(project_id, featurestore_id, bucket:"testbucket")
    parsed_json = JSON.parse(json_result)
    expect_status(201)
    connector_id = parsed_json["id"]
    @s3_connector_id = connector_id
  end

  def get_featuregroup(project_id, featurestore_id, name, version)
    get_featuregroup_endpoint = "#{ENV['HOPSWORKS_API']}/project/#{project_id}/featurestores/#{featurestore_id}/featuregroups/#{name}?version=#{version}"
    pp "get #{get_featuregroup_endpoint}" if defined?(@debugOpt) && @debugOpt
    result = get get_featuregroup_endpoint
    expect_status(200)
    parsed_result = JSON.parse(result)
    pp parsed_result if (defined?(@debugOpt)) && @debugOpt
    parsed_result
  end

  def get_trainingdataset(project_id, featurestore_id, name, version)
    get_trainingdataset_endpoint = "#{ENV['HOPSWORKS_API']}/project/#{project_id}/featurestores/#{featurestore_id}/trainingdatasets/#{name}?version=#{version}"
    pp "get #{get_trainingdataset_endpoint}" if defined?(@debugOpt) && @debugOpt
    result = get get_trainingdataset_endpoint
    expect_status(200)
    parsed_result = JSON.parse(result)
    pp parsed_result if (defined?(@debugOpt)) && @debugOpt
    parsed_result
  end

  def delete_featuregroup_checked(project_id, featurestore_id, fg_id)
    delete_featuregroup_endpoint = "#{ENV['HOPSWORKS_API']}/project/#{project_id}/featurestores/#{featurestore_id}/featuregroups/#{fg_id}"
    pp "delete #{delete_featuregroup_endpoint}" if defined?(@debugOpt) && @debugOpt
    delete delete_featuregroup_endpoint
    expect_status_details(200)
  end

  def delete_trainingdataset_checked(project_id, featurestore_id, td_id)
    delete_trainingdataset_endpoint = "#{ENV['HOPSWORKS_API']}/project/#{project_id}/featurestores/#{featurestore_id}/trainingdatasets/#{td_id}"
    pp "delete #{delete_trainingdataset_endpoint}" if defined?(@debugOpt) && @debugOpt
    delete delete_trainingdataset_endpoint
    expect_status_details(200)
  end
end