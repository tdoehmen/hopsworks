/*
 * Changes to this file committed after and not including commit-id: ccc0d2c5f9a5ac661e60e6eaf138de7889928b8b
 * are released under the following license:
 *
 * This file is part of Hopsworks
 * Copyright (C) 2018, Logical Clocks AB. All rights reserved
 *
 * Hopsworks is free software: you can redistribute it and/or modify it under the terms of
 * the GNU Affero General Public License as published by the Free Software Foundation,
 * either version 3 of the License, or (at your option) any later version.
 *
 * Hopsworks is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along with this program.
 * If not, see <https://www.gnu.org/licenses/>.
 *
 * Changes to this file committed before and including commit-id: ccc0d2c5f9a5ac661e60e6eaf138de7889928b8b
 * are released under the following license:
 *
 * Copyright (C) 2013 - 2018, Logical Clocks AB and RISE SICS AB. All rights reserved
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software, and to permit
 * persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS  OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package io.hops.hopsworks.common.opensearch;

import io.hops.hopsworks.common.util.Settings;

import javax.ejb.EJB;
import javax.ejb.Schedule;
import javax.ejb.Singleton;
import javax.ejb.Timer;
import java.util.Map;
import java.util.function.Function;
import java.util.logging.Level;
import java.util.logging.Logger;

@Singleton
public class OpenSearchCleaner {

  private final static Logger LOGGER = Logger.getLogger(OpenSearchCleaner.class.getName());

  @EJB
  OpenSearchClientController elasticClientCtrl;
  @EJB
  Settings settings;

  /**
   * Periodically remove job/notebooks log indexes. Runs once per day and removed indices older than 7 days.
   *
   * @param timer timer
   */
  @Schedule(persistent = false, minute = "0", hour = "1")
  public void deleteLogIndices(Timer timer) {
    LOGGER.log(Level.INFO, "Running OpenSearchCleaner.");
    //Get all log indices
    try {
      Function<org.opensearch.common.settings.Settings, Long> creationTimeParser = settings -> {
        try {
          return Long.parseLong(settings.get("index.creation_date"));
        } catch(NumberFormatException | NullPointerException e) {
          return -1L;
        }
      };
      String indexRegex = "(" + Settings.OPENSEARCH_LOG_INDEX_REGEX + ")" +
          "|(" + Settings.OPENSEARCH_SERVING_INDEX_REGEX + ")" +
          "|(" + Settings.OPENSEARCH_SERVICES_INDEX_REGEX + ")";
      Map<String, Long> indices = elasticClientCtrl.mngIndicesGetByRegex(indexRegex, creationTimeParser);
      for (String index : indices.keySet()) {
        //Get current timestamp
        long currentTime = System.currentTimeMillis();
        long indexCreationTime = indices.get(index);
        if (currentTime - indexCreationTime > settings.getOpenSearchLogsIndexExpiration()) {
          //If index was created before the threshold, delete it asynchronously. If operation fails
          //we log it and the next day it will be retried.
          elasticClientCtrl.mngIndexDelete(index);
          LOGGER.log(Level.INFO, "Deletedindex:{0}", index);
        }
      }
    } catch (Exception ex) {
      LOGGER.log(Level.SEVERE, "Index deletion failed", ex);
    }
  }
}
